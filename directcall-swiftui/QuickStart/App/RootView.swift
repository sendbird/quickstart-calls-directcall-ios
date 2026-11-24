//
//  RootView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Intents
import SwiftUI

/// Shows the sign-in screen or the main tabs, depending on whether a user is signed in,
/// and shows the call screen over them while a call is active.
struct RootView: View {
    private var auth: AuthService { .shared }
    private var router: CallRouter { .shared }
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if auth.isSignedIn {
                MainTabView()
            } else {
                SignInView()
            }
        }
        // A call can become active before this view appears, for example when the user answered on the lock screen.
        // The call screen still shows because the router, not this view, keeps the active call.
        .fullScreenCover(item: activeCall) { activeCall in
            CallView(activeCall: activeCall)
        }
        // The user tapped a call of this app in the Phone app's Recents. See `QuickStartIntent`.
        // With the SwiftUI app life cycle, the activity arrives here, not in the app delegate.
        .onContinueUserActivity(String(describing: INStartCallIntent.self)) { userActivity in
            guard let request = StartCallRequest(userActivity: userActivity) else { return }
            Task {
                do {
                    // The app may have just launched and not be signed in yet.
                    try await auth.authenticateIfNeeded()
                    try await Dialer.dial(calleeId: request.calleeId, isVideoCall: request.isVideoCall)
                } catch {
                    errorMessage = "Couldn't retrieve a recent call.\n\(error.localizedDescription)"
                }
            }
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
        .errorAlert($errorMessage)
    }

    private var activeCall: Binding<ActiveCall?> {
        Binding(
            get: { router.activeCall },
            set: { newValue in
                if newValue == nil, let callId = router.activeCall?.callId {
                    router.dismiss(callId: callId)
                }
            }
        )
    }
}
