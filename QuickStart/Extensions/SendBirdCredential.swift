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
    
    struct SendBirdCredential: Decodable {
        let appId: String
        let userId: String
        let accessToken: String?
        
        enum CredentialKey: String, CodingKey {
            case appId = "app_id"
            case userId = "user_id"
            case accessToken = "access_token"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SendBirdCredential.CredentialKey.self)
            
            self.appId = try container.decode(String.self, forKey: .appId)
            self.userId = try container.decode(String.self, forKey: .userId)
            self.accessToken = try? container.decode(String.self, forKey: .accessToken)
        }
    }
    
    static let shared = SendBirdCredentialManager()
    
    weak var delegate: SignInDelegate?
    
    /// Take `Data` object and reture result
    func decode(base64EncodedData data: Data, completion: @escaping (SendBirdCredential?, Error?) -> Void) {
        do {
            let credential = try JSONDecoder().decode(SendBirdCredential.self, from: data)
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didSignIn(appId: credential.appId,
                                          userId: credential.userId,
                                          accessToken: credential.accessToken)
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
}

