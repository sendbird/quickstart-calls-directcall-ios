//
//  StartCallRequest.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Intents

/// A call to start from outside the app, such as from the Phone app's Recents.
///
/// When the user taps a call that CallKit added to Recents, the system sends `INStartCallIntent`
/// to the Intents extension (`QuickStartIntent`), which opens this app with that intent.
struct StartCallRequest: Equatable {
    let calleeId: String
    let isVideoCall: Bool
}

extension StartCallRequest {
    init?(intent: INIntent?) {
        guard let intent = intent as? INStartCallIntent,
              let calleeId = intent.contacts?.first?.personHandle?.value else { return nil }
        self.init(calleeId: calleeId, isVideoCall: intent.callCapability == .videoCall)
    }

    init?(userActivity: NSUserActivity) {
        self.init(intent: userActivity.interaction?.intent)
    }
}
