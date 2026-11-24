//
//  Dialer.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SendBirdCalls

/// Makes an outgoing call and shows the call screen.
@MainActor
enum Dialer {
    static func dial(calleeId: String, isVideoCall: Bool) async throws {
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: isVideoCall, useFrontCamera: true)
        let params = DialParams(calleeId: calleeId, isVideoCall: isVideoCall, callOptions: callOptions, customItems: [:])

        let call = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DirectCall, Error>) in
            SendBirdCall.dial(with: params) { call, error in
                if let call, error == nil {
                    continuation.resume(returning: call)
                } else {
                    continuation.resume(throwing: error ?? CredentialError.unknown)
                }
            }
        }
        CallRouter.shared.present(call, isDialing: true)
    }
}
