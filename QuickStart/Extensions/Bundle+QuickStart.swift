//
//  Bundle+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation

extension Bundle {
    var version: String {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let infoDict = NSDictionary.init(contentsOfFile: path),
            let sampleUIVersion = infoDict["CFBundleShortVersionString"] as? String {
                return sampleUIVersion
        }
        return ""
    }
    
    var appName: String? {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let infoDict = NSDictionary.init(contentsOfFile: path),
            let appName = infoDict["CFBundleName"] as? String {
                return appName
        }
        return ""
    }
}
