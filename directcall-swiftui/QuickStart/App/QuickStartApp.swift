//
//  QuickStartApp.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

@main
struct QuickStartApp: App {
    // VoIP pushes and CallKit need an app delegate. See `AppDelegate`.
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
