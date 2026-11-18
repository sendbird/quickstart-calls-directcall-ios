//
//  AppInfoView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SendBirdCalls
import SwiftUI

/// Shows the Sendbird application that this app is connected to.
struct AppInfoView: View {
    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "No app name"
    }

    var body: some View {
        List {
            LabeledContent("Name", value: appName)
            LabeledContent("ID") {
                Text(SendBirdCall.appId ?? "No configured app ID")
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Application information")
        .navigationBarTitleDisplayMode(.inline)
    }
}
