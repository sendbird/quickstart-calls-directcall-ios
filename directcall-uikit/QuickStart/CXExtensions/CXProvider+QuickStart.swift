//
//  CXProvider+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import CallKit
import UIKit

extension CXProviderConfiguration {
    // The app's provider configuration, representing its CallKit capabilities
    static var `default`: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(localizedName: "Sendbird Calls")
        if let image = UIImage(named: "icLogoSymbolInverse") {
            providerConfiguration.iconTemplateImageData = image.pngData()
        }
        // Even if `.supportsVideo` has `false` value, SendBirdCalls supports video call.
        // However, it needs to be `true` if you want to make video call from native call log, so called "Recents"
        // and update correct type of call log in Recents
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        
        // Set up ringing sound
        // If you want to set up other sounds such as dialing, reconnecting and reconnected, see `AppDelegate+SoundEffects.swift` file.
         providerConfiguration.ringtoneSound = "Ringing.mp3"
        
        return providerConfiguration
    }
}

extension CXProvider {
    static var `default`: CXProvider {
        CXProvider(configuration: .`default`)
    }
}
