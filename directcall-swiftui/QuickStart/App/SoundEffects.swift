//
//  SoundEffects.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SendBirdCalls

enum SoundEffects {
    /// Plays sounds while dialing and while reconnecting.
    /// CallKit plays the ringtone of incoming calls. See `CallKitManager`.
    static func register() {
        SendBirdCall.addDirectCallSound("Dialing.mp3", forType: .dialing)
        SendBirdCall.addDirectCallSound("ConnectionLost.mp3", forType: .reconnecting)
        SendBirdCall.addDirectCallSound("ConnectionRestored.mp3", forType: .reconnected)
        // To remove a sound, use `SendBirdCall.removeDirectCallSound(forType:)`.
    }
}
