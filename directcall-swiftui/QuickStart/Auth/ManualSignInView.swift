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

    private var trimmedAppId: String { appId.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedUserId: String { userId.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Application ID", text: $appId)
                    TextField("User ID", text: $userId)
                    TextField("Access token (optional)", text: $accessToken)
                } footer: {
                    Text("Find the application ID on the Sendbird Dashboard.")
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
            .navigationTitle("Sign in manually")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sign in") {
                        let token = accessToken.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSubmit(Credential(appId: trimmedAppId, userId: trimmedUserId, accessToken: token.isEmpty ? nil : token))
                        dismiss()
                    }
                    .disabled(trimmedAppId.isEmpty || trimmedUserId.isEmpty)
                }
            }
        }
    }
}
