//
//  CallTextTests.swift
//  QuickStartTests
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import AVFoundation
import SendBirdCalls
import XCTest
@testable import QuickStart

final class CallTextTests: XCTestCase {
    func test_duration_underAnHour_showsMinutesAndSeconds() {
        XCTAssertEqual(CallText.duration(milliseconds: 0), "00:00")
        XCTAssertEqual(CallText.duration(milliseconds: 65_000), "01:05")
    }

    func test_duration_overAnHour_showsHoursMinutesAndSeconds() {
        XCTAssertEqual(CallText.duration(milliseconds: 3_725_000), "1:02:05")
    }

    func test_endResult_readableSentenceCase() {
        XCTAssertEqual(CallText.endResult(.noAnswer), "No answer")
        XCTAssertEqual(CallText.endResult(.otherDeviceAccepted), "Other device accepted")
        XCTAssertEqual(CallText.endResult(.completed), "Completed")
    }

    func test_audioOutputImageName_byPort() {
        XCTAssertEqual(CallText.audioOutputImageName(for: .bluetoothHFP), "btnBluetoothSelected")
        XCTAssertEqual(CallText.audioOutputImageName(for: .bluetoothA2DP), "btnBluetoothSelected")
        XCTAssertEqual(CallText.audioOutputImageName(for: .builtInSpeaker), "btnSpeakerSelected")
        XCTAssertEqual(CallText.audioOutputImageName(for: .builtInReceiver), "btnSpeaker")
    }
}
