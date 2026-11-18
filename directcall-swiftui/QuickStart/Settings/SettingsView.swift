//
//  SettingsView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

/// Shows the signed-in user and the application information, and signs out.
struct SettingsView: View {
    private var credential: Credential? { AuthService.shared.currentCredential }
    @State private var isConfirmingSignOut = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        ProfileImage(url: credential?.profileURL)
                            .frame(width: 56, height: 56)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(credential?.nickname?.isEmpty == false ? credential?.nickname ?? "" : "—")
                                .font(.headline)
                            Text("User ID \(credential?.userId ?? "")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section {
                    NavigationLink("Application information") {
                        AppInfoView()
                    }
                    Button("Sign out", role: .destructive) {
                        isConfirmingSignOut = true
                    }
                } footer: {
                    Text(AppInfo.versionDescription)
                }
            }
            .navigationTitle("Settings")
            .alert("Do you want to sign out?", isPresented: $isConfirmingSignOut) {
                Button("Cancel", role: .cancel) { }
                Button("Sign out", role: .destructive) { signOut() }
            } message: {
                Text("If you sign out, you cannot receive any calls.")
            }
            .alert("Couldn’t sign out",
                   isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func signOut() {
        Task {
            do {
                try await AuthService.shared.signOut()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
