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
            guard let userId = userDefault.value(forKey: "com.sendbird.quickstart.calls.user.id") as? String else { return ("", nil, nil) }
            let username = userDefault.value(forKey: "com.sendbird.quickstart.calls.user.name") as? String
            let profile = userDefault.value(forKey: "com.sendbird.quickstart.calls.user.profile") as? String
            return (userId, username, profile)
        }
        set {
            let userDefault = UserDefaults.standard
            userDefault.setValue(newValue.id, forKey: "com.sendbird.quickstart.calls.user.id")
            userDefault.setValue(newValue.name, forKey: "com.sendbird.quickstart.calls.user.name")
            userDefault.setValue(newValue.profile, forKey: "com.sendbird.quickstart.calls.user.profile")
        }
    }
    
    var autoLogin: Bool {
        get {
            return UserDefaults.standard.value(forKey: "com.sendbird.quickstart.calls.auto.login") as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.sendbird.quickstart.calls.auto.login")
        }
    }
    
    var pushToken: Data? {
        get {
            guard let pushToken = UserDefaults.standard.value(forKey: "com.sendbird.quickstart.calls.pushtoken") as? Data else { return nil }
            return pushToken
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.sendbird.quickstart.calls.pushtoken")
        }
    }
}
