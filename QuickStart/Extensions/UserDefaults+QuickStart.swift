//
//  UserDefaults+QuickStart.swift
//  QuickStart Swift
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation

extension UserDefaults {
    var user: (id: String, name: String?, profile: String?) {
        get {
            let userDefault = UserDefaults.standard
            guard let userId = userDefault.value(forKey: "com.sendbird.calls.quickstart.user.id") as? String else { return ("", nil, nil) }
            let username = userDefault.value(forKey: "com.sendbird.calls.quickstart.user.name") as? String
            let profile = userDefault.value(forKey: "com.sendbird.calls.quickstart.user.profile") as? String
            return (userId, username, profile)
        }
        set {
            let userDefault = UserDefaults.standard
            userDefault.setValue(newValue.id, forKey: "com.sendbird.calls.quickstart.user.id")
            userDefault.setValue(newValue.name, forKey: "com.sendbird.calls.quickstart.user.name")
            userDefault.setValue(newValue.profile, forKey: "com.sendbird.calls.quickstart.user.profile")
        }
    }
    
    var autoLogin: Bool {
        get {
            return UserDefaults.standard.value(forKey: "com.sendbird.calls.quickstart.autologin") as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.sendbird.calls.quickstart.autologin")
        }
    }
    
    var accessToken: String? {
        get {
            guard let accessToken = UserDefaults.standard.value(forKey: "com.sendbird.calls.quickstart.accesstoken") as? String else {
                return nil
            }
            return accessToken
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.sendbird.calls.quickstart.accesstoken")
        }
    }
    
    var pushToken: Data? {
        get {
            guard let pushToken = UserDefaults.standard.value(forKey: "com.sendbird.calls.quickstart.pushtoken") as? Data else { return nil }
            return pushToken
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.sendbird.calls.quickstart.pushtoken")
        }
    }
}
