//
//  DialError.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/09/22.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

enum DialErrors: String, Error {
    case emptyUserID = "User ID is required."
    case voiceCallFailed = "Couldn't make call"
    case videoCallFailed = "Couldn't make video call"
    case unknown = "Something went wrong. Try again."
    case getLogFailed = "Couldn't retrieve recent call."
}
