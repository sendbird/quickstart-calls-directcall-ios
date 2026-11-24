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
        VStack(alignment: .leading, spacing: 0) {
            item(title: "Name", value: appName)
            item(title: "ID", value: SendBirdCall.appId ?? "No configured app ID")
            Spacer()
        }
        .background(.white)
        .navigationTitle("Application Information")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func item(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.tertiaryText)
                Text(value)
                    .font(.system(size: 14))
                    .textSelection(.enabled)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 15)
            Rectangle()
                .fill(Theme.divider)
                .frame(height: 1)
        }
    }
}
