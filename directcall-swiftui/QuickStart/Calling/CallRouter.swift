//
//  CallRouter.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Foundation
import Observation
import SendBirdCalls

/// The call that the call screen shows.
struct ActiveCall: Identifiable, Equatable {
    let callId: String
    /// `true` when this device dialed the call and it is still connecting.
    let isDialing: Bool

    var id: String { callId }
}

/// Decides which call the call screen shows. `RootView` presents the call screen while `activeCall` is set.
///
/// Calls can start outside SwiftUI, for example when the user answers on the CallKit screen,
/// so this object, not a view, keeps the state.
@MainActor
@Observable
final class CallRouter {
    static let shared = CallRouter()

    private(set) var activeCall: ActiveCall?

    func present(_ call: DirectCall, isDialing: Bool) {
        show(ActiveCall(callId: call.callId, isDialing: isDialing))
    }

    func show(_ call: ActiveCall) {
        // Answering on the CallKit screen and other paths can show the same call more than once.
        guard activeCall?.callId != call.callId else { return }
        activeCall = call
    }

    /// Closes the call screen only when it still shows `callId`, so that an ended call does not close a newer one.
    func dismiss(callId: String) {
        guard activeCall?.callId == callId else { return }
        activeCall = nil
    }
}
