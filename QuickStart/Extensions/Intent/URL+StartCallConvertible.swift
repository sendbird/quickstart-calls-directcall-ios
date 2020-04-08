//
//  URL+StartCallConvertible.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/08.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

extension URL: StartCallConvertible {
    private struct Constants {
        static let URLScheme = "QuickStart"
    }

    var calleeId: String? {
        guard scheme == Constants.URLScheme else { return nil }
        return host
    }
}
