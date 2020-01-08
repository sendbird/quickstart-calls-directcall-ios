//
//  UILabel+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UILabel {
    func setUp(text: String, color: UIColor, font: UIFont) {
        self.text = text
        self.textColor = color
        self.font = font
    }
    
    func updateId(_ id: String) {
        self.setUp(text: id, color: .lightPurple, font: .systemFont(ofSize: 13))
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.alpha = 1.0
        }
        
        animator.startAnimation()
    }
}
