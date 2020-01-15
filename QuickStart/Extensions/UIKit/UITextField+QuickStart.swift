//
//  UITextField+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UITextField {
    var filteredText: String? {
        get {
            return text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
