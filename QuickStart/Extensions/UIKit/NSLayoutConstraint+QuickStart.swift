//
//  NSLayoutConstraint+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func setup(value: CGFloat) {
        self.constant = value
    }
    
    func animate(value: CGFloat) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.constant = value
        }
        
        animator.startAnimation()
    }
}
