//
//  DialError.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/09/22.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

enum DialErrors: Error {
    case emptyUserID
    case voiceCallFailed(error: Error?)
    case videoCallFailed(error: Error?)
    case unknown
    case getLogFailed
    
    var localizedDescription: String {
        switch self {
            case .emptyUserID: return "User ID is required."
            case .voiceCallFailed(let error): return "Couldn't make call.\n\(error?.localizedDescription ?? "")"
            case .videoCallFailed(let error): return "Couldn't make video call.\n\(error?.localizedDescription ?? "")"
            case .unknown: return "Something went wrong. Try again."
            case .getLogFailed: return "Couldn't retrieve a recent call."
        }
    }
}
