//
//  AppInfo.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Foundation
import SendBirdCalls

enum AppInfo {
    static var sampleVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }

    /// For example, `QuickStart 1.0.0   SDK 1.12.3`.
    static var versionDescription: String {
        "QuickStart \(sampleVersion)   SDK \(SendBirdCall.sdkVersion)"
    }
}
