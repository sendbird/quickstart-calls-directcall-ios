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

// MARK: Design
extension UITextField {
    @IBInspectable
    var padding: CGFloat {
        get {
            self.leftView?.frame.width ?? 0.0
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.height))
            self.leftView = paddingView
            self.leftViewMode = UITextField.ViewMode.always
        }
    }
}
