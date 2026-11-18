//
//  CallHistoryStore.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Foundation
import Observation
import SendBirdCalls

/// Keeps the call history on this device, newest first, and fills it from Sendbird when it is empty.
@MainActor
@Observable
final class CallHistoryStore {
    static let shared = CallHistoryStore()

    // The UIKit sample stores its history in a different format under its own key, so this sample uses a new key.
    private static let key = "com.sendbird.calls.quickstart.swiftui.callhistories"

    private let defaults: UserDefaults
    private(set) var items: [CallHistory]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.key),
           let items = try? JSONDecoder().decode([CallHistory].self, from: data) {
            self.items = items
        } else {
            self.items = []
        }
    }

    func insert(_ item: CallHistory) {
        merge([item])
    }

    /// Adds histories that are not in the list yet. A history with an ID already in the list is ignored.
    func merge(_ newItems: [CallHistory]) {
        var itemsById = Dictionary(items.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for item in newItems where itemsById[item.id] == nil {
            itemsById[item.id] = item
        }
        items = itemsById.values.sorted { $0.startedAt > $1.startedAt }
        save()
    }

    func clear() {
        items = []
        defaults.removeObject(forKey: Self.key)
    }

    /// Loads the call logs of the signed-in user from Sendbird when this device has no history yet,
    /// for example right after signing in on a new device.
    func loadFromServerIfEmpty() {
        guard items.isEmpty else { return }
        let params = DirectCallLogListQuery.Params()
        params.limit = 100
        // `nil` when no user is signed in.
        guard let query = SendBirdCall.createDirectCallLogListQuery(with: params) else { return }
        fetchNextPage(of: query)
    }

    private func fetchNextPage(of query: DirectCallLogListQuery) {
        query.next { [weak self] callLogs, _ in
            guard let self, let callLogs, !callLogs.isEmpty else { return }
            self.merge(callLogs.map(CallHistory.init(callLog:)))
            self.fetchNextPage(of: query)
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
