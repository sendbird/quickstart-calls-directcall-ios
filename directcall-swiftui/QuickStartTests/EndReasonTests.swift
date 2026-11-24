//
//  EndReasonTests.swift
//  QuickStartTests
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import CallKit
import SendBirdCalls
import XCTest
@testable import QuickStart

final class EndReasonTests: XCTestCase {
    func test_cxEndedReason_mapping() {
        let expected: [(DirectCallEndResult, CXCallEndedReason?)] = [
            (.connectionLost, .failed),
            (.timedOut, .failed),
            (.acceptFailed, .failed),
            (.dialFailed, .failed),
            (.unknown, .failed),
            (.notConnected, .failed),
            (.completed, .remoteEnded),
            (.canceled, .remoteEnded),
            (.declined, .declinedElsewhere),
            (.noAnswer, .unanswered),
            (.otherDeviceAccepted, .answeredElsewhere),
            (.none, nil),
        ]

        for (result, reason) in expected {
            XCTAssertEqual(result.cxEndedReason, reason, "DirectCallEndResult(rawValue: \(result.rawValue))")
        }
    }
}
