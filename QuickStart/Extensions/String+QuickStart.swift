//
//  String+QuickStart.swift
//  QuickStart
//
//  Created by Damon Park on 2020/03/26.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation
extension String {
    public var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var isEmptyOrWhitespace: Bool {
        return self.trimmed.isEmpty
    }
    
    public var collapsed: String? {
        if self.isEmptyOrWhitespace {
            return nil
        } else {
            return self.trimmed
        }
    }
    
    func unwrapNickname() -> String {
        guard self.isEmptyOrWhitespace else { return "—" }
        return self
    }
}
