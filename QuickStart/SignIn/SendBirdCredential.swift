//
//  SendBirdCredential.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/08/07.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation
import UIKit

class SendBirdCredentialManager {
    enum CredentialError: Swift.Error {
        case invalidURL
        
        var localizedDescription: String {
            switch self {
            case .invalidURL: return "Invalid URL"
            }
        }
    }
    
    struct SendBirdCredential: Codable {
        let appID: String
        let userID: String
        let accessToken: String?
        // User details
        let nickname: String?
        let profileURL: String?
        
        enum CredentialKey: String, CodingKey {
            case appID = "app_id"
            case userID = "user_id"
            case accessToken = "access_token"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SendBirdCredential.CredentialKey.self)
            
            self.appID = try container.decode(String.self, forKey: .appID)
            self.userID = try container.decode(String.self, forKey: .userID)
            self.accessToken = try? container.decode(String.self, forKey: .accessToken)
            
            self.nickname = nil
            self.profileURL = nil
        }
        
        init(appID: String, userID: String, accessToken: String?, nickname: String? = nil, profileURL: String? = nil) {
            self.appID = appID
            self.userID = userID
            self.accessToken = accessToken
            self.nickname = nickname
            self.profileURL = profileURL
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CredentialKey.self)
            
            try container.encode(appID, forKey: .appID)
            try container.encode(userID, forKey: .userID)
            try? container.encode(accessToken, forKey: .accessToken)
        }
        
        func details(nickname: String? = nil, profileURL: String? = nil) -> SendBirdCredential {
            let credential = SendBirdCredential(appID: self.appID, userID: self.userID, accessToken: self.accessToken, nickname: nickname, profileURL: profileURL)
            return credential
        }
    }
    
    static let shared = SendBirdCredentialManager()
    private static let urlScheme = "sendbird://"
    
    weak var delegate: SignInDelegate?
    
    /// Handle URL scheme containg `sendbird://` as a prefix and signs in.
    ///  - Parameters:
    ///     - url: URL from URL scheme.
    /// - Returns: The boolean value indicating whether the url is valid or not.
    func handle(url: URL) -> Bool {
        // Check URL validation
        guard url.absoluteString.contains(SendBirdCredentialManager.urlScheme) else { return false }
        
        do {
            let credential = try self.decode(url: url)
            self.signIn(with: credential)
        } catch {
            UIApplication.shared.showError(with: error.localizedDescription)
        }
        
        return true
    }
    
    /// Handle data from QR code and signs in.
    /// - Parameters:
    ///     - qrData: The data from QR code.
    ///     - completion: The completion handler that allows you to handle the result.
    func handle(qrData: Data, onSucceed: () -> Void, onFailed: (Error) -> Void) {
        // Decoding
        do {
            let credential = try self.decode(base64EncodedData: qrData)
            self.signIn(with: credential)
            onSucceed()
        } catch {
            onFailed(error)
        }
    }
    
    /// Take `Data` object and reture result
    private func decode(base64EncodedData data: Data) throws -> SendBirdCredential {
        return try JSONDecoder().decode(SendBirdCredential.self, from: data)
    }
    
    private func decode(url: URL) throws -> SendBirdCredential {
        let stringValue = url.absoluteString.replacingOccurrences(of: SendBirdCredentialManager.urlScheme, with: "")
        guard let data = Data(base64Encoded: stringValue) else { throw CredentialError.invalidURL }
        return try self.decode(base64EncodedData: data)
    }
    
    private func signIn(with credential: SendBirdCredential) {
        // Refer to `SignInWithQRViewController.didSignIn`
        guard let delegate = self.delegate else {
            UserDefaults.standard.credential = credential
            return
        }
        delegate.processSignIn(credential: credential)
    }
}
