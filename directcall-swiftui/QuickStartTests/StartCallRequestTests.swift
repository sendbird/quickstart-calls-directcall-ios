//
//  StartCallRequestTests.swift
//  QuickStartTests
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Intents
import XCTest
@testable import QuickStart

final class StartCallRequestTests: XCTestCase {
    private func intent(contact: String?, capability: INCallCapability) -> INStartCallIntent {
        let contacts = contact.map { value in
            [INPerson(personHandle: INPersonHandle(value: value, type: .unknown),
                      nameComponents: nil, displayName: nil, image: nil, contactIdentifier: nil, customIdentifier: nil)]
        }
        return INStartCallIntent(callRecordFilter: nil, callRecordToCallBack: nil, audioRoute: .unknown,
                                 destinationType: .normal, contacts: contacts, callCapability: capability)
    }

    func test_videoCallIntent_returnsVideoRequest() {
        let request = StartCallRequest(intent: intent(contact: "bob", capability: .videoCall))

        XCTAssertEqual(request, StartCallRequest(calleeId: "bob", isVideoCall: true))
    }

    func test_audioCallIntent_returnsVoiceRequest() {
        let request = StartCallRequest(intent: intent(contact: "bob", capability: .audioCall))

        XCTAssertEqual(request, StartCallRequest(calleeId: "bob", isVideoCall: false))
    }

    func test_intentWithoutContact_returnsNil() {
        XCTAssertNil(StartCallRequest(intent: intent(contact: nil, capability: .audioCall)))
    }
}
