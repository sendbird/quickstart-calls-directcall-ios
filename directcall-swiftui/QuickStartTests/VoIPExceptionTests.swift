//
//  VoIPExceptionTests.swift
//  QuickStartTests
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import PushKit
import SendBirdCalls
import XCTest
@testable import QuickStart

/// iOS requires a CallKit report for every VoIP push, before PushKit's completion is called.
///
/// The tests pass fake VoIP pushes to Sendbird Calls through `PushKitHandler`, and record, in order, when a call that
/// ends right away (a placeholder) is reported and when PushKit's completion is called.
@MainActor
final class VoIPExceptionTests: XCTestCase {
    private enum Event: Equatable {
        case placeholderFromPushKitHandler
        case placeholderFromCallEventHandler
        case pushKitCompletion
    }

    /// A class, so that the handlers' closures and the test share the same list.
    private final class EventLog {
        var events: [Event] = []
    }

    /// `PKPushPayload` has no public initializer that takes a payload, so the test overrides `dictionaryPayload`.
    private final class FakePushPayload: PKPushPayload {
        private let payload: [AnyHashable: Any]

        init(_ payload: [AnyHashable: Any]) {
            self.payload = payload
            super.init()
        }

        override var dictionaryPayload: [AnyHashable: Any] { payload }
    }

    private let registry = PKPushRegistry(queue: .main)
    private var log = EventLog()
    private var pushKitHandler: PushKitHandler!
    /// Sendbird Calls keeps its delegates weakly, so the test keeps this one.
    private var callEventHandler: CallEventHandler!
    private var callIds: [String] = []

    override func setUp() {
        super.setUp()
        // The app configures Sendbird Calls when the user signs in. The tests don't sign in, so configure it here.
        // No request reaches a server: the application ID only has to be set.
        SendBirdCall.configure(appId: "00000000-0000-0000-0000-000000000000")

        log = EventLog()
        let log = log
        pushKitHandler = PushKitHandler(reportPlaceholderCall: { log.events.append(.placeholderFromPushKitHandler) })
        callEventHandler = CallEventHandler(reportPlaceholderCall: { log.events.append(.placeholderFromCallEventHandler) })
        // Replace the app's handler, which `AppDelegate` added with the same identifier.
        SendBirdCall.addDelegate(callEventHandler, identifier: CallEventHandler.delegateIdentifier)
    }

    override func tearDown() {
        // End the calls that the pushes created, so that they don't ring into the next test.
        for callId in callIds {
            SendBirdCall.getCall(forCallId: callId)?.end()
        }
        callIds = []
        SendBirdCall.addDelegate(CallEventHandler.shared, identifier: CallEventHandler.delegateIdentifier)
        super.tearDown()
    }

    // MARK: - Tests

    func test_pushWithoutCall_reportsPlaceholderBeforePushKitCompletion() {
        receive(["aps": ["alert": "hello"]])

        XCTAssertEqual(log.events, [.placeholderFromPushKitHandler, .pushKitCompletion])
    }

    /// The first push of a call creates it, and `didStartRinging(_:)` reports it. No placeholder is needed.
    func test_firstPushOfCall_reportsNoPlaceholder() {
        receive(dialPayload(callId: newCallId()))

        XCTAssertEqual(log.events, [.pushKitCompletion])
    }

    /// The same push again, for example when APNs delivers it twice. Sendbird Calls already handled the call,
    /// so it calls `didReceiveVoIPException(_:)` instead of `didStartRinging(_:)`.
    func test_secondPushOfSameCall_reportsOnePlaceholderBeforePushKitCompletion() {
        let payload = dialPayload(callId: newCallId())
        receive(payload)
        log.events.removeAll()

        receive(payload)

        XCTAssertEqual(log.events, [.placeholderFromCallEventHandler, .pushKitCompletion])
    }

    /// The placeholder is a separate call: the call that is already ringing keeps ringing.
    func test_secondPushOfSameCall_doesNotEndRingingCall() throws {
        let callId = newCallId()
        let payload = dialPayload(callId: callId)
        receive(payload)

        receive(payload)

        let call = try XCTUnwrap(SendBirdCall.getCall(forCallId: callId))
        XCTAssertFalse(call.isEnded)
    }

    // MARK: - Helpers

    /// Passes the payload to the handler, and waits until it calls PushKit's completion.
    private func receive(_ payload: [AnyHashable: Any]) {
        let completed = expectation(description: "PushKit completion")
        let log = log
        pushKitHandler.pushRegistry(registry, didReceiveIncomingPushWith: FakePushPayload(payload), for: .voIP) {
            log.events.append(.pushKitCompletion)
            completed.fulfill()
        }
        wait(for: [completed], timeout: 5)
    }

    private func newCallId() -> String {
        let callId = UUID().uuidString.lowercased()
        callIds.append(callId)
        return callId
    }

    /// The VoIP payload of an incoming 1:1 call (`dial`), in the layout that Sendbird Calls decodes.
    private func dialPayload(callId: String) -> [AnyHashable: Any] {
        let user: (String, String) -> [String: Any] = { userId, role in
            ["user_id": userId, "nickname": userId, "is_active": true, "role": role]
        }
        return [
            "sendbird_call": [
                "command": [
                    "version": 1,
                    "message_id": UUID().uuidString,
                    "cmd": "CALL",
                    "type": "dial",
                    "call_type": "direct_call",
                    "payload": [
                        "call_id": callId,
                        "is_video_call": false,
                        "caller": user("caller", "dc_caller"),
                        "callee": user("callee", "dc_callee"),
                        "turn_credential": [
                            "turn_urls": ["turn:turn.example.com"],
                            "username": "username",
                            "password": "password",
                        ] as [String: Any],
                        "constraints": ["audio": true, "video": false],
                        "sbcall_short_lived_token": "token",
                        "custom_items": [String: String](),
                    ] as [String: Any],
                ] as [String: Any],
            ] as [String: Any],
        ]
    }
}
