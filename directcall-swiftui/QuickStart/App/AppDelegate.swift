//
//  AppDelegate.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SendBirdCalls
import UIKit

/// Sets up Sendbird Calls at launch.
///
/// VoIP pushes can launch the app in the background before any SwiftUI view exists,
/// so incoming call handling starts here, not in a view.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // This sample gets the application ID when the user signs in with a QR code or by hand.
        // To use your own application ID in code instead, call `SendBirdCall.configure(appId: "YOUR_APP_ID")` here.

        // Receive incoming calls through `didStartRinging(_:)`.
        SendBirdCall.addDelegate(CallEventHandler.shared, identifier: CallEventHandler.delegateIdentifier)
        // Register for VoIP pushes to receive incoming calls in the background.
        PushKitHandler.shared.register()
        SoundEffects.register()

        // Sign in again with the stored credential. If it fails, the sign-in screen shows.
        Task { try? await AuthService.shared.autoSignIn() }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // End ongoing calls when the app is terminated. iOS gives only a short time,
        // so some calls might not end before the app stops.
        for cxCall in CallKitManager.shared.currentCalls {
            guard let call = SendBirdCall.getCall(forUUID: cxCall.uuid) else { continue }
            call.end()
            CallKitManager.shared.endCall(call)
        }
    }
}
