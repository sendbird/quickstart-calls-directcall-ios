//
//  CallHistory.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Foundation
import SendBirdCalls

/// One row of the call history.
// TODO(CLNP-9098 Task A5): Add the fields shown in the call history list.
struct CallHistory: Codable, Identifiable {
    let id: String

    init(callLog: DirectCallLog) {
        self.id = callLog.callId
    }
}
