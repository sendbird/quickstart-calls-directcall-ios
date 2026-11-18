//
//  Data+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation

extension Data {
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
