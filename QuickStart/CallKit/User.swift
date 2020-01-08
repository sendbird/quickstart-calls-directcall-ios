//
//  User.swift
//  V2oIP
//
//  Created by Jaesung Lee on 2019/11/04.
//  Copyright © 2019 SendBird. All rights reserved.
//

/**
 This class represents a caller and a callee
 
 - note: User Information
     ```json
     {
       "user_id": String,
       "nickname": String,
       "profile_url": String,
       "metadata: [{"key":"value"}, ...],
       "is_active: Boolean
     }
     ```
 
 - Since: 1.0.0
 */
public class User: Codable {
    /**
     The user ID of the call user.
     
     - Since: 1.0.0
     */
    public let userId: String
    
    /**
     (Optional value) The nickname of the call user.
     
     - Since: 1.0.0
     */
    public var nickname: String?
    
    /**
     (Optional value) The profile image URL of the call user.
     
     - Since: 1.0.0
     */
    public var profileURL: String?
    
    /**
     (Optional value) If `true`, the call user uses audio.
     
     - Since: 1.0.0
     */
    public var isAudioEnabled: Bool?
    
    /**
     (Optional value) If `true`, the call user uses video.
     
     - Since: 1.0.0
     */
    public var isVideoEnabled: Bool?
    
    public var metaData: [String: String]?
    
    public var isActive: Bool?
    
    /**
     This method initalize the call user with user information.
     - Parameters:
        - userInfo: json data that contains user information
     
     - returns: `User` object.
     
     - note:
         ```json
          {
            "user_id": String,
            "nickname": String,
            "profile_url": String,
            "metadata: [{"key":"value"}, ...],
            "is_active: Boolean
          }
         ```
     */
    
    init(userId: String) {
        self.userId = userId
    }
    
    
    convenience init(with userInfo: [String: Any?]) {
        guard let userId = userInfo["user_id"] as? String else {
            fatalError("init(with:) has not been implemented")
        }
        
        self.init(userId: userId)
        
        self.initiate(userInfo)
    }
    
    
    func initiate(_ userInfo: [String: Any?]) {
        self.nickname = userInfo["nickname"] as? String
        self.profileURL = userInfo["profile_url"] as? String
        self.metaData = userInfo["meta_data"] as? [String: String]
        self.isActive = userInfo["is_active"] as? Bool
    }
    
    func update(with userInfo: [String: Any?]) {
        self.nickname = userInfo["nickname"] as? String
        self.profileURL = userInfo["profile_url"] as? String
        self.metaData = userInfo["meta_data"] as? [String: String]
        self.isActive = userInfo["is_active"] as? Bool
    }
    
    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname = "nickname"
        case profileURL = "profile_url"
        case metaData = "meta_data"
        case isActive = "is_active"
    }

}

/**
 Test Class
 */

class UserTest {
    let userInfo: [String: Any?] = [
        "user_id": "chic0815",
        "nickname": nil,
        "profile_url": nil,
    ]

    var user: User?
//
//    func run() {
//        self.user = User(userId: userInfo["user_id"] as! String ?? "")
//        self.user.initiate(with: userInfo)
//        print("userId: \"\(user.userId)\"")
//        print("nickname: \"\(user.nickname!)\"")
//        print("profileURL: \"\(user.profileURL!)\"")
//    }

}
