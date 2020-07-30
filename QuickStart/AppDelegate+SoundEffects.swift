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
    func setDirectCallSounds() {
        // SendBirdCall.setDirectCallSound("Ringing.mp3", forKey: .ringing)
        SendBirdCall.setDirectCallSound("Dialing.mp3", forKey: .dialing)
        SendBirdCall.setDirectCallSound("ConnectionLost.mp3", forKey: .reconnecting)
        SendBirdCall.setDirectCallSound("ConnectionRestored.mp3", forKey: .reconnected)
    }
}
