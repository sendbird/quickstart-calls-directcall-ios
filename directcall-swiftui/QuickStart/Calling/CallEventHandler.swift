//
//  CallEventHandler.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import CallKit
import SendBirdCalls

/// Handles call events that arrive while no call screen is open, such as a new incoming call.
///
/// Once the call screen opens, `CallSession` becomes the call's `delegate` and handles its events instead.
final class CallEventHandler: NSObject, SendBirdCallDelegate, DirectCallDelegate {
    static let shared = CallEventHandler()
    /// The identifier that `AppDelegate` adds `shared` with. Sendbird Calls keeps one delegate per identifier.
    static let delegateIdentifier = "com.sendbird.calls.quickstart.delegate"

    private let reportPlaceholderCall: () -> Void

    /// - Parameter reportPlaceholderCall: Reports a call that ends right away. Tests replace it.
    init(reportPlaceholderCall: @escaping () -> Void = { CallKitManager.shared.reportPlaceholderCall() }) {
        self.reportPlaceholderCall = reportPlaceholderCall
        super.init()
    }

    // MARK: - SendBirdCallDelegate

    /// A VoIP push of a call that Sendbird Calls already handled, for example when the same push arrives twice,
    /// or when it arrives after the call ended.
    ///
    /// iOS still requires a CallKit report for this push. Reporting `ongoingCall` again would fail or end the call
    /// that is already ringing, so report a separate call that ends right away. Sendbird Calls calls this before the
    /// completion handler of `pushRegistry(_:didReceiveIncomingPushWith:for:completionHandler:)`, so the report comes
    /// before PushKit's completion in `PushKitHandler`.
    func didReceiveVoIPException(_ ongoingCall: DirectCall) {
        reportPlaceholderCall()
    }

    /// A new incoming call. Report it to CallKit, which shows the system incoming call screen.
    func didStartRinging(_ call: DirectCall) {
        call.delegate = self

        guard let uuid = call.callUUID, CallKitManager.shared.shouldProcessCall(uuid: uuid) else { return }

        let name = call.caller?.userId ?? "Unknown"
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: name)
        update.localizedCallerName = name
        update.hasVideo = call.isVideoCall

        if SendBirdCall.getOngoingCallCount() > 1 {
            // This sample handles one call at a time. CallKit still needs the report, so report the call and decline it.
            CallKitManager.shared.reportIncomingCall(uuid: uuid, update: update) { _ in
                CallKitManager.shared.reportEnded(uuid: uuid, reason: .declined)
            }
            call.end()
        } else {
            CallKitManager.shared.reportIncomingCall(uuid: uuid, update: update)
        }
    }

    // MARK: - DirectCallDelegate

    func didConnect(_ call: DirectCall) { }

    /// The call ended before the call screen opened, for example when the user declined it on the CallKit screen.
    func didEnd(_ call: DirectCall) {
        CallKitManager.shared.reportEnded(uuid: call.callUUID ?? UUID(), reason: call.endResult)
        guard let callLog = call.callLog else { return }
        Task { @MainActor in
            CallHistoryStore.shared.insert(CallHistory(callLog: callLog))
        }
    }
}
