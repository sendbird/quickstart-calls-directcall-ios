//
//  RootView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

/// Shows the sign-in screen or the main tabs, depending on whether a user is signed in.
struct RootView: View {
    private var auth: AuthService { .shared }
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if auth.isSignedIn {
                MainTabView()
            } else {
                SignInView()
            }
        }
        .task {
            // Sign in again with the stored credential. If it fails, the sign-in screen shows.
            try? await auth.autoSignIn()
        }
        .onOpenURL { url in
            // With the SwiftUI app life cycle, `sendbird://` URLs arrive here, not in the app delegate.
            Task {
                do {
                    try await auth.signIn(url: url)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        .alert("Couldn’t sign in", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}
