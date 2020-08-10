//
//  SendBirdCredential.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/08/07.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

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
        }
        
        init(appID: String, userID: String, accessToken: String?) {
            self.appID = appID
            self.userID = userID
            self.accessToken = accessToken
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CredentialKey.self)
            
            try container.encode(appID, forKey: .appID)
            try container.encode(userID, forKey: .userID)
            try? container.encode(accessToken, forKey: .accessToken)
        }
    }
    
    static let shared = SendBirdCredentialManager()
    
    weak var delegate: SignInDelegate? {
        didSet {
            // Start "auto sign in" when the Sign In view has been loaded.
            guard let credential = UserDefaults.standard.credential else { return }
            SendBirdCredentialManager.shared.signIn(with: credential)
        }
    }
    
    var currentCredentail: SendBirdCredential? {
        get { UserDefaults.standard.credential }
    }
    
    /// Take `Data` object and reture result
    func decode(base64EncodedData data: Data, completion: @escaping (SendBirdCredential?, Error?) -> Void) {
        do {
            let credential = try JSONDecoder().decode(SendBirdCredential.self, from: data)
            DispatchQueue.main.async {
                completion(credential, nil)
            }
        } catch {
            DispatchQueue.main.async { completion(nil, error) }
        }
    }
    
    func decode(url: URL, completion: @escaping (SendBirdCredential?, Error?) -> Void) {
        let stringValue = url.absoluteString.replacingOccurrences(of: "sendbird://", with: "")
        guard let data = Data(base64Encoded: stringValue) else {
            DispatchQueue.main.async { completion(nil, CredentialError.invalidURL) }
            return
        }
        
        self.decode(base64EncodedData: data, completion: completion)
    }
    
    func signIn(with credential: SendBirdCredential) {
        if let delegate = self.delegate {
            // Refer to `SignInWithQRViewController.didSignIn`
            delegate.didSignIn(credential: credential)
        } else {
            UserDefaults.standard.credential = credential
        }
    }
}
