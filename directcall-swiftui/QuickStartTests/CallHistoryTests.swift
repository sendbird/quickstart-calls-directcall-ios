//
//  CallHistoryTests.swift
//  QuickStartTests
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import XCTest
@testable import QuickStart

@MainActor
final class CallHistoryTests: XCTestCase {
    private let suiteName = "com.sendbird.calls.quickstart.tests.CallHistoryTests"
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func history(_ id: String, startedAt: Int64, endResult: String = "Completed") -> CallHistory {
        CallHistory(id: id, isOutgoing: true, hasVideo: false, remoteUserId: "U", remoteNickname: "N",
                    remoteProfileURL: nil, startedAt: startedAt, duration: 0, endResult: endResult)
    }

    func test_insert_sameId_keepsOne() {
        let store = CallHistoryStore(defaults: defaults)

        // The call screen and the incoming call handler can both record the same call.
        store.insert(history("A", startedAt: 1, endResult: "Completed"))
        store.insert(history("A", startedAt: 1, endResult: "Declined"))

        XCTAssertEqual(store.items.map(\.id), ["A"])
        XCTAssertEqual(store.items.first?.endResult, "Completed")
    }

    func test_merge_sortsNewestFirst() {
        let store = CallHistoryStore(defaults: defaults)
        store.insert(history("A", startedAt: 1))

        store.merge([history("C", startedAt: 3), history("B", startedAt: 2)])

        XCTAssertEqual(store.items.map(\.id), ["C", "B", "A"])
    }

    func test_items_persistAcrossStores() {
        CallHistoryStore(defaults: defaults).insert(history("A", startedAt: 1))

        XCTAssertEqual(CallHistoryStore(defaults: defaults).items.map(\.id), ["A"])
    }

    func test_clear_removesItems() {
        let store = CallHistoryStore(defaults: defaults)
        store.insert(history("A", startedAt: 1))

        store.clear()

        XCTAssertTrue(store.items.isEmpty)
        XCTAssertTrue(CallHistoryStore(defaults: defaults).items.isEmpty)
    }

    func test_formatStartedAt_yearBoundary() throws {
        let seoul = try XCTUnwrap(TimeZone(identifier: "Asia/Seoul"))
        var components = DateComponents(year: 2025, month: 12, day: 29, hour: 0, minute: 0)
        components.timeZone = seoul
        let date = try XCTUnwrap(Calendar(identifier: .gregorian).date(from: components))
        let milliseconds = Int64(date.timeIntervalSince1970 * 1000)

        // With the week-based year (`YYYY`), this date shows as 2026.
        XCTAssertEqual(CallHistory.formatStartedAt(milliseconds, timeZone: seoul), "2025/12/29 00:00")
    }
}
