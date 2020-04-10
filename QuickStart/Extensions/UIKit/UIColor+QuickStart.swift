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
        case blue
        case lightGray
        
        var color: UIColor {
            switch self {
            case .black:        return UIColor.black.withAlphaComponent(0.12)
            case .white:        return UIColor.white.withAlphaComponent(0.88)
            case .purple:       return UIColor.init(r: 130, g: 94,  b: 235)
            case .lightPurple:  return UIColor.init(r: 202, g: 196, b: 255)
            case .blue:         return UIColor.init(r: 123, g: 83,  b: 239)
            case .lightGray:    return UIColor.init(r: 240, g: 240, b: 240)
            }
        }
        
        var cgColor: CGColor { self.color.cgColor }
    }
}

extension UIColor {
    fileprivate convenience init(hexStr: String, alpha: CGFloat = 1.0){
        var rgbValue: UInt32 = 0
        let trimedHexStr = hexStr.trimmingCharacters(in: CharacterSet.whitespaces)
        let scanner: Scanner = Scanner(string: trimedHexStr)
        
        scanner.scanLocation = 1    //by pass '#'
        scanner.scanHexInt32(&rgbValue)
        
        let rgbRed: CGFloat = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let rgbGreen: CGFloat = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let rgbBlue: CGFloat = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: rgbRed, green: rgbGreen, blue: rgbBlue, alpha: alpha)
    }
    
    fileprivate convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0){
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }
}
