//
//  UserDefaults+QuickStart.swift
//  QuickStart Swift
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Key: String, CaseIterable {
        case appId
        case user
        case accessToken
        case autoLogin
        case voipPushToken
        case callHistories
        
        var value: String { "com.sendbird.calls.quickstart.\(self.rawValue.lowercased())" }
    }
    
}

extension UserDefaults {
    var appId: String? {
        get { UserDefaults.standard.get(objectType: String.self, forKey: Key.appId.value) }
        set { UserDefaults.standard.set(object: newValue, forKey: Key.appId.value) }
    }
    
    var user: (userId: String, name: String?, profile: String?) {
        get { UserDefaults.standard.get(objectType: UserDefaults.User.self, forKey: Key.user.value)?.value ?? User.empty }
        set { UserDefaults.standard.set(object: UserDefaults.User(userId: newValue.userId, name: newValue.name, profile: newValue.profile), forKey: Key.user.value) }
    }
    
    var autoLogin: Bool {
        get { UserDefaults.standard.get(objectType: Bool.self, forKey: Key.autoLogin.value) ?? false }
        set { UserDefaults.standard.set(object: newValue, forKey: Key.autoLogin.value) }
    }
    
    var accessToken: String? {
        get { UserDefaults.standard.get(objectType: String.self, forKey: Key.accessToken.value) }
        set { UserDefaults.standard.set(object: newValue, forKey: Key.accessToken.value) }
    }
    
    var voipPushToken: Data? {
        get { UserDefaults.standard.get(objectType: Data.self, forKey: Key.voipPushToken.value) }
        set { UserDefaults.standard.set(object: newValue, forKey: Key.voipPushToken.value) }
    }
    
    var callHistories: [CallHistory] {
        get { UserDefaults.standard.get(objectType: [CallHistory].self, forKey: Key.callHistories.value) ?? [] }
        set { UserDefaults.standard.set(object: newValue, forKey: Key.callHistories.value) }
    }
}

extension UserDefaults {
    func clear() {
        let keys = Key.allCases.filter { $0 != .voipPushToken }
        keys.map { $0.value }.forEach(UserDefaults.standard.removeObject)
    }
}

extension UserDefaults {
    fileprivate struct User: Codable {
        let userId: String
        let name: String?
        let profile: String?
        
        var value: (userId: String, name: String?, profile: String?) { (userId: userId, name: name, profile: profile) }
        static var empty: (userId: String, name: String?, profile: String?) { (userId: "", name: nil, profile: nil) }
    }
}

extension UserDefaults {
    func set<T: Codable>(object: T, forKey: String) {
        guard let jsonData = try? JSONEncoder().encode(object) else { return }
        set(jsonData, forKey: forKey)
    }

    func get<T: Codable>(objectType: T.Type, forKey: String) -> T? {
        guard let result = value(forKey: forKey) as? Data else { return nil }
        return try? JSONDecoder().decode(objectType, from: result)
    }
}
