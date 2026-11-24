//
//  UITextView+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UITextView {
    func rounding() {
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = true
    }
    
    func border() {
        self.layer.borderColor = UIColor.QuickStart.purple.cgColor
        self.layer.borderWidth = 1.0
    }
}
