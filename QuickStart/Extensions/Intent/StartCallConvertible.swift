//
//  StartCallConvertible.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/08.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

protocol StartCallConvertible {
    var calleeId: String? { get }
    var hasVideo: Bool? { get }
}

extension StartCallConvertible {
    var hasVideo: Bool? { nil }
}
