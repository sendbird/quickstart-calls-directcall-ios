//
//  CredentialTests.swift
//  QuickStartTests
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import XCTest
@testable import QuickStart

final class CredentialTests: XCTestCase {
    private let json = #"{"app_id":"A","user_id":"U","access_token":"T"}"#

    func test_decodeURL_returnsCredential() throws {
        let base64 = Data(json.utf8).base64EncodedString()
        let url = try XCTUnwrap(URL(string: "sendbird://" + base64))

        let credential = try Credential.decode(url: url)

        XCTAssertEqual(credential, Credential(appId: "A", userId: "U", accessToken: "T"))
    }

    func test_decodeURL_invalidBase64_throwsInvalidURL() throws {
        let url = try XCTUnwrap(URL(string: "sendbird://not-base64!"))

        XCTAssertThrowsError(try Credential.decode(url: url)) { error in
            XCTAssertEqual(error as? CredentialError, .invalidURL)
        }
    }

    func test_decodeQR_returnsCredential() throws {
        let credential = try Credential.decode(qrData: Data(json.utf8))

        XCTAssertEqual(credential, Credential(appId: "A", userId: "U", accessToken: "T"))
    }
}
