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
    @State private var isShowingAppInfo = false
    @State private var isConfirmingSignOut = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            // A fixed stack with its own lines, not a `List`: a list aligns its separators with the first text of each row,
            // so the separator under the centered profile would start in the middle of the screen.
            // The lines sit where the UIKit sample's storyboard puts them: under the profile, and above and below "Sign out".
            VStack(spacing: 0) {
                profile
                    .overlay(alignment: .bottom) { divider }
                menuRow(image: "iconInfo", title: "Application information", showsDisclosure: true) {
                    isShowingAppInfo = true
                }
                menuRow(image: "iconLeave", title: "Sign out") {
                    isConfirmingSignOut = true
                }
                .overlay(alignment: .top) { divider }
                .overlay(alignment: .bottom) { divider }
                Text(AppInfo.versionDescription)
                    .font(.footnote)
                    .foregroundStyle(Theme.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 18)
                Spacer(minLength: 0)
            }
            .padding(.top, 18)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isShowingAppInfo) {
                AppInfoView()
            }
            .alert("Do you want to sign out?", isPresented: $isConfirmingSignOut) {
                Button("Sign Out") { signOut() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("If you sign out, you cannot receive any calls.")
            }
            .errorAlert($errorMessage)
        }
        .tint(Theme.purple)
    }

    private var profile: some View {
        VStack(spacing: 0) {
            ProfileImage(url: credential?.profileURL)
                .frame(width: 64, height: 64)
            Text(credential?.displayNickname ?? "-")
                .font(.system(size: 23))
                .padding(.top, 8)
            Text("User ID: \(credential?.userId ?? "-")")
                .font(.system(size: 12))
                .foregroundStyle(Theme.tertiaryText)
                .padding(.top, 4)
        }
        .padding(.top, 4)
        .frame(maxWidth: .infinity)
        .frame(height: 140, alignment: .top)
    }

    /// The same 1 pt line as the UIKit sample, 16 pt in from both edges.
    private var divider: some View {
        Rectangle()
            .fill(Theme.divider)
            .frame(height: 1)
            .padding(.horizontal, 16)
    }

    private func menuRow(image: String, title: String, showsDisclosure: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.system(size: 17))
                    .foregroundStyle(.black)
                Spacer()
                if showsDisclosure {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
