//
//  UITextField+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UITextField {
    var filteredText: String? { text?.trimmed }
}

// MARK: Design
extension UITextField {
    @IBInspectable var isPaddingEnabled: Bool {
        get {
            guard let paddingView = self.leftView else { return false }
            return paddingView.frame.width != 0
        }
        set {
            guard newValue else { return }
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.height))
            self.leftView = paddingView
            self.leftViewMode = UITextField.ViewMode.always
        }
    }
}
