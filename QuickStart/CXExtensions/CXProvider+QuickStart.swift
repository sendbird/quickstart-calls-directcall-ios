//
//  CXProvider+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import CallKit

extension CXProviderConfiguration {
    // The app's provider configuration, representing its CallKit capabilities
    static var `default`: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(localizedName: "com.sendbird.calls.quickstart.cxprovider")
        
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        
        return providerConfiguration
    }
}

extension CXProvider {
    static var `default`: CXProvider {
        return CXProvider(configuration: .`default`)
    }
}
