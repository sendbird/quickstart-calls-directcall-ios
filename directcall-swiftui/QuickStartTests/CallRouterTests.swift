//
//  CallRouterTests.swift
//  QuickStartTests
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import XCTest
@testable import QuickStart

@MainActor
final class CallRouterTests: XCTestCase {
    func test_show_whileSameCallIsActive_keepsFirst() {
        let router = CallRouter()

        router.show(ActiveCall(callId: "A", isDialing: true))
        router.show(ActiveCall(callId: "A", isDialing: false))

        XCTAssertEqual(router.activeCall, ActiveCall(callId: "A", isDialing: true))
    }

    func test_show_otherCall_replacesActiveCall() {
        let router = CallRouter()

        router.show(ActiveCall(callId: "A", isDialing: false))
        router.show(ActiveCall(callId: "B", isDialing: false))

        XCTAssertEqual(router.activeCall?.callId, "B")
    }

    func test_dismiss_otherCallId_keepsActiveCall() {
        let router = CallRouter()
        router.show(ActiveCall(callId: "B", isDialing: false))

        // An ended call ("A") closes its screen late, after a new call ("B") is already shown.
        router.dismiss(callId: "A")

        XCTAssertEqual(router.activeCall?.callId, "B")
    }

    func test_dismiss_activeCallId_clearsActiveCall() {
        let router = CallRouter()
        router.show(ActiveCall(callId: "A", isDialing: false))

        router.dismiss(callId: "A")

        XCTAssertNil(router.activeCall)
    }
}
