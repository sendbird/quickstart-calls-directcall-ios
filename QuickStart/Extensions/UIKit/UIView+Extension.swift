//
//  UIView+Extension.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/09.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

// MARK: For Video View
extension UIView {
    func embed(_ videoView: SendBirdVideoView) {
        self.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": videoView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": videoView]))
        self.layoutIfNeeded()
    }
}

// MARK: For Storyboard
extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            if newValue > 0 {
                self.clipsToBounds = true
            }
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
}
