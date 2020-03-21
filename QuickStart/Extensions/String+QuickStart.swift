//
//  String+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/21.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

extension String {
    func removeSlash() -> String {
        return self.replacingOccurrences(of: "\\", with: "")
    }
}
