//
//  PushKitHandler.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import PushKit
import SendBirdCalls

/// Receives VoIP pushes for incoming calls, including when the app is not running.
final class PushKitHandler: NSObject, PKPushRegistryDelegate {
    static let shared = PushKitHandler()

    private var registry: PKPushRegistry?
    private let reportPlaceholderCall: () -> Void

    /// - Parameter reportPlaceholderCall: Reports a call that ends right away. Tests replace it.
    init(reportPlaceholderCall: @escaping () -> Void = { CallKitManager.shared.reportPlaceholderCall() }) {
        self.reportPlaceholderCall = reportPlaceholderCall
        super.init()
    }

    /// Call this at launch, in `application(_:didFinishLaunchingWithOptions:)`, so that VoIP pushes are handled
    /// even when the push itself launched the app and no SwiftUI view exists yet.
    func register() {
        let registry = PKPushRegistry(queue: .main)
        registry.delegate = self
        registry.desiredPushTypes = [.voIP]
        self.registry = registry
    }

    // MARK: - PKPushRegistryDelegate

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        CredentialStore().voipPushToken = pushCredentials.token
        SendBirdCall.registerVoIPPush(token: pushCredentials.token, unique: true) { error in
            if let error {
                print("[QuickStart] Failed to register the VoIP push token: \(error)")
            }
        }
    }

    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        // Sendbird Calls handles the push and calls `didStartRinging(_:)`, which reports the call to CallKit.
        // For a call that it already handled, it calls `didReceiveVoIPException(_:)` instead. See `CallEventHandler`.
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) { uuid in
            if uuid == nil {
                // iOS terminates apps that receive a VoIP push without reporting a call to CallKit.
                // When the push has no valid call, report one and end it right away.
                self.reportPlaceholderCall()
            }
            completion()
        }
    }
}
