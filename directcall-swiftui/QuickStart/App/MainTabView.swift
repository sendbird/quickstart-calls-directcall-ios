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
            CallHistoryView()
                .tabItem { Label("History", image: "iconCallHistory") }
            SettingsView()
                .tabItem { Label("Settings", image: "icSettings") }
        }
    }
}
