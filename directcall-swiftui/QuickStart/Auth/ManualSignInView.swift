//
//  ManualSignInView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

/// Enters the application ID, user ID, and access token by hand instead of scanning a QR code.
struct ManualSignInView: View {
    let onSubmit: (Credential) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var appId = ""
    @State private var userId = ""
    @State private var accessToken = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                InputField(placeholder: "Application ID", text: $appId)
                InputField(placeholder: "User ID", text: $userId)
                InputField(placeholder: "Access token (optional)", text: $accessToken)
                Button("Sign in") { submit() }
                    .buttonStyle(FilledButtonStyle())
                    .padding(.top, 16)
                Spacer()
                Text(AppInfo.versionDescription)
                    .font(.footnote)
                    .foregroundStyle(Theme.tertiaryText)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .background(.white)
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .tint(Theme.purple)
                }
            }
            .errorAlert($errorMessage)
        }
    }

    private func submit() {
        let appId = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        let userId = userId.trimmingCharacters(in: .whitespacesAndNewlines)
        let accessToken = accessToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !appId.isEmpty else {
            errorMessage = "Please enter valid app ID"
            return
        }
        guard !userId.isEmpty else {
            errorMessage = "Please enter valid user ID"
            return
        }
        onSubmit(Credential(appId: appId, userId: userId, accessToken: accessToken.isEmpty ? nil : accessToken))
        dismiss()
    }
}
