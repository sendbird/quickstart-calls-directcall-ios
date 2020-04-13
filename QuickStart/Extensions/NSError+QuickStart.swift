//
//  NSError+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/13.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

extension NSError {
    
    static var failedImageLoad: NSError {
        let error = NSError(domain: "com.sendbird.quickstart.error.local",
            code: 400001,
            userInfo: [NSLocalizedDescriptionKey: "Failed to load image."])
        
        return error
    }
}
