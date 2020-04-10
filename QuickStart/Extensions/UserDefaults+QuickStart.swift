//
//  UserDefaults+QuickStart.swift
//  QuickStart Swift
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Key : String, CaseIterable {
        case appId
        case user
        case accessToken
        case autoLogin
        case voipPushToken
        
        var value: String { "com.sendbird.calls.quickstart.\(self.rawValue.lowercased())" }
    }
    
}

extension UserDefaults {
    var appId: String? {
        get { UserDefaults.standard.get(objectType: String.self, forKey: Key.appId.value) }
        set { UserDefaults.standard.set(object: newValue, forKey: Key.appId.value) }
    }
    
    var user: (id: String, name: String?, profile: String?) {
        get { UserDefaults.standard.get(objectType: UserDefaults.User.self, forKey: Key.user.value)?.value ?? User.empty }
        set { UserDefaults.standard.set(object: UserDefaults.User(id: newValue.id, name: newValue.name, profile: newValue.profile), forKey: Key.user.value) }
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
}

extension UserDefaults {
    func clear() {
        let keys = Key.allCases.filter { $0 != .voipPushToken }
        keys.map{$0.value}.forEach(UserDefaults.standard.removeObject)
    }
}

extension UserDefaults {
    fileprivate struct User: Codable {
        let id: String
        let name: String?
        let profile: String?
        
        var value: (id: String, name: String?, profile: String?) { (id: id, name: name, profile: profile) }
        static var empty: (id: String, name: String?, profile: String?) { (id: "", name: nil, profile: nil) }
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
