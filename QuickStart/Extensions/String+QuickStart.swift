//
//  String+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation

extension String {
    static var version: String?  {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let infoDict = NSDictionary.init(contentsOfFile: path), let sampleUIVersion = infoDict["CFBundleShortVersionString"] as? String {
                let version = sampleUIVersion
                return version
            }
            return nil
        }
        return nil
    }
}
