//
//  AppDelegate+SoundEffects.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/07/30.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import SendBirdCalls

// MARK: DirectCall sound effects
// If you use CallKit framework, you have to set ringing sound by using `CXProviderConfiguration.ringtoneSound`. See `CXProvider+QuickStart.swift` file.
extension AppDelegate {
    func addDirectCallSounds() {
        // SendBirdCall.setDirectCallSound("Ringing.mp3", forKey: .ringing)
        SendBirdCall.addDirectCallSound("Dialing.mp3", forType: .dialing)
        SendBirdCall.addDirectCallSound("ConnectionLost.mp3", forType: .reconnecting)
        SendBirdCall.addDirectCallSound("ConnectionRestored.mp3", forType: .reconnected)
        
        // If you want to remove added DirectCall sounds,
        // Use `SendBirdCall.removeDirectCallSound(forType:)`
    }
}
