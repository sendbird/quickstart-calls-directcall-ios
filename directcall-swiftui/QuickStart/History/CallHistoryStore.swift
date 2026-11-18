//
//  CallHistoryStore.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Foundation
import Observation

/// Keeps the call history on this device.
// TODO(CLNP-9098 Task A5): Store the history and publish it to the call history list.
@MainActor
@Observable
final class CallHistoryStore {
    static let shared = CallHistoryStore()

    func insert(_ item: CallHistory) { }
}
