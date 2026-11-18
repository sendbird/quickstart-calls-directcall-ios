//
//  MainTabView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

/// The main screen after signing in.
struct MainTabView: View {
    var body: some View {
        TabView {
            DialView()
                .tabItem { Label("Call", image: "icCall") }
            // TODO(CLNP-9098 Task A5): Replace with `CallHistoryView`.
            Text("History")
                .tabItem { Label("History", image: "iconCallHistory") }
            // TODO(CLNP-9098 Task A5): Replace with `SettingsView`.
            Text("Settings")
                .tabItem { Label("Settings", image: "icSettings") }
        }
    }
}
