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
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var isEmptyOrWhitespace: Bool {
        self.trimmed.isEmpty
    }
    
    public var collapsed: String? {
        if self.isEmptyOrWhitespace {
            return nil
        } else {
            return self.trimmed
        }
    }
    
    public func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

extension Optional where Wrapped == String {
    /// Unwraps optional value with replacement.
    ///
    /// - Parameters:
    ///     - replacement: When the unwrapped value is invalid(`nil` or empty `String`), this method will return replacement.
    ///     - checkWhiteSpace: The value for checking white space.
    ///
    /// - Note: Set `checkWhiteSpace` to `false` when you don't want to check white space of nickname.
    func unwrap(with replacement: String, checkWhiteSpace: Bool = true) -> String {
        guard let unwrappedValue = self else { return replacement }
        // Check empty string or whitespace if needed
        if checkWhiteSpace, unwrappedValue.isEmptyOrWhitespace { return replacement }
        return unwrappedValue
    }
}
