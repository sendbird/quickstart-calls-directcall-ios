//
//  MainTabView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

/// The main screen after signing in. The tabs show only icons, and the selected tab shows a filled icon.
struct MainTabView: View {
    private enum Tab {
        case dial, history, settings
    }

    @State private var selection = Tab.dial

    var body: some View {
        TabView(selection: $selection) {
            DialView()
                .tabItem { Image(selection == .dial ? "icCallFilled" : "icCall") }
                .tag(Tab.dial)
            CallHistoryView()
                .tabItem { Image(selection == .history ? "icLayoutDefaultFilled" : "icLayoutDefault") }
                .tag(Tab.history)
            SettingsView()
                .tabItem { Image(selection == .settings ? "iconSettingsFilled" : "icSettings") }
                .tag(Tab.settings)
        }
        .tint(.black)
    }
}
