//
//  CredentialStore.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Foundation

/// Keeps the signed-in credential and the VoIP push token in `UserDefaults`.
struct CredentialStore {
    private enum Key {
        static let credential = "com.sendbird.calls.quickstart.credential"
        static let voipPushToken = "com.sendbird.calls.quickstart.voippushtoken"
    }

    var defaults: UserDefaults = .standard

    var credential: Credential? {
        get {
            guard let data = defaults.data(forKey: Key.credential) else { return nil }
            return try? JSONDecoder().decode(Credential.self, from: data)
        }
        nonmutating set {
            guard let newValue, let data = try? JSONEncoder().encode(newValue) else {
                defaults.removeObject(forKey: Key.credential)
                return
            }
            defaults.set(data, forKey: Key.credential)
        }
    }

    /// Stays after signing out so that the next user can register it again.
    var voipPushToken: Data? {
        get { defaults.data(forKey: Key.voipPushToken) }
        nonmutating set { defaults.set(newValue, forKey: Key.voipPushToken) }
    }

    /// Removes the signed-in user's information. The VoIP push token is kept.
    func clear() {
        credential = nil
    }
}
