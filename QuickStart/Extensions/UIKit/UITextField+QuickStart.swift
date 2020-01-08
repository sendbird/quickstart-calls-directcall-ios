//
//  UITextField+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UITextField {
    func setup(_ text: String?, placeholder: String) {
        self.setUpPlaceholder(placeholder: placeholder, alignment: .left)
        self.text = text
    }
    
    func setUpPlaceholder(placeholder: String, alignment: NSTextAlignment) {
        self.placeholder = placeholder
        self.textAlignment = alignment
    }
    
    func fetchUserId() {
        self.text = UserDefaults.standard.user.id
    }
    
    func fetchNickname() {
        self.text = UserDefaults.standard.user.name
    }
    
    var filteredText: String? {
        get {
            return text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
