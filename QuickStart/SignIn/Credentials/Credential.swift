//
//  Credential.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/09/17.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation
import SendBirdCalls

/// A Structure containing app ID, access token and user information.
struct Credential: Codable {
    let appID: String
    let userID: String
    let accessToken: String?
    let nickname: String?
    let profileURL: String?
    
    enum CredentialKey: String, CodingKey {
        case appID = "app_id"
        case userID = "user_id"
        case accessToken = "access_token"
        case nickname = "nickname"
        case profileURL = "profile_url"
    }
    
    /// Initializes `Credential` object with access token. The app ID and user informations are fetched from `SendBirdCall`.
    init(accessToken: String?) {
        self.init(appID: SendBirdCall.appId ?? "",
                  userID: SendBirdCall.currentUser?.userId ?? "",
                  accessToken: accessToken,
                  nickname: SendBirdCall.currentUser?.nickname,
                  profileURL: SendBirdCall.currentUser?.profileURL)
    }
    
    /// Initializes `Credential` object.
    init(appID: String, userID: String, accessToken: String?, nickname: String? = nil, profileURL: String? = nil) {
        self.appID = appID
        self.userID = userID
        self.accessToken = accessToken
        self.nickname = nickname
        self.profileURL = profileURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Credential.CredentialKey.self)
        
        self.appID = try container.decode(String.self, forKey: .appID)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.accessToken = try? container.decode(String.self, forKey: .accessToken)
        
        self.nickname = try? container.decode(String.self, forKey: .nickname)
        self.profileURL = try? container.decode(String.self, forKey: .profileURL)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CredentialKey.self)
        
        try container.encode(appID, forKey: .appID)
        try container.encode(userID, forKey: .userID)
        try? container.encode(accessToken, forKey: .accessToken)
        try? container.encode(nickname, forKey: .nickname)
        try? container.encode(profileURL, forKey: .profileURL)
    }
}
