//
//  CredentialStoreTests.swift
//  QuickStartTests
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import XCTest
@testable import QuickStart

final class CredentialStoreTests: XCTestCase {
    private let suiteName = "com.sendbird.calls.quickstart.tests.CredentialStoreTests"
    private var defaults: UserDefaults!
    private var store: CredentialStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        store = CredentialStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func test_credential_roundTrip() {
        let credential = Credential(appId: "A", userId: "U", accessToken: nil, nickname: "N", profileURL: nil)

        store.credential = credential

        XCTAssertEqual(CredentialStore(defaults: defaults).credential, credential)
    }

    func test_clear_removesCredentialButKeepsVoIPPushToken() {
        store.credential = Credential(appId: "A", userId: "U", accessToken: nil)
        store.voipPushToken = Data([0x01, 0x02])

        store.clear()

        XCTAssertNil(store.credential)
        XCTAssertEqual(store.voipPushToken, Data([0x01, 0x02]))
    }
}
