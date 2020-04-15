//
//  UIColor+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UIColor {
    enum QuickStart {
        case black
        case white
        case purple
        case lightPurple
        case lightGray
        
        var color: UIColor {
            switch self {
            case .black:        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
            case .white:        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.88)
            case .purple:       return #colorLiteral(red: 0.509719789, green: 0.368627451, blue: 0.9215686275, alpha: 1)
            case .lightPurple:  return #colorLiteral(red: 0.7921568627, green: 0.768627451, blue: 1, alpha: 1)
            case .lightGray:    return #colorLiteral(red: 0.9410942197, green: 0.9412292838, blue: 0.9410645366, alpha: 1)
            }
        }
        
        var cgColor: CGColor { self.color.cgColor }
    }
}
