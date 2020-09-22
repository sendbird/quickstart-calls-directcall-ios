//
//  CallStatus.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/09/22.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

enum CallStatus {
    case connecting
    case muted(String)
    case ended(String)
    
    var message: String {
        switch self {
            case .connecting: return "call connecting..."
            case .muted(let user): return "\(user) is muted"
            case .ended(let result): return result.replacingOccurrences(of: "_", with: " ")
        }
    }
}
