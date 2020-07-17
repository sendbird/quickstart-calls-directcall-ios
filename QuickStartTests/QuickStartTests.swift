//
//  QuickStartTests.swift
//  QuickStartTests
//
//  Created by Jaesung Lee on 2020/05/04.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import XCTest
@testable import SendBird_Calls

class QuickStartTests: XCTestCase {

    // MARK: Test for ImageCacheError
    func test_failedToLoadImage() {
        let expectation = XCTestExpectation()
        self.continueAfterFailure = false
        
        guard let profileURL = URL(string: "wrong-profile-url") else {
            XCTFail("Failed to generate URL from string")
            return
        }
        
        ImageCache.shared.load(url: profileURL) { _, error in
            guard let error = error as? ImageCache.ImageCacheError else {
                XCTFail("There is no error even it has a wrong URL")
                return
            }
            XCTAssertEqual(error, ImageCache.ImageCacheError.failedToLoadImage)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }

}
