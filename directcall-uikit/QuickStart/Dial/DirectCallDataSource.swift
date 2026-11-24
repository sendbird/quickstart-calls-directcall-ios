//
//  DirectCallDataSource.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/18.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

protocol DirectCallDataSource {
    var call: DirectCall! { get set }
    
    var isDialing: Bool? { get set }
}
