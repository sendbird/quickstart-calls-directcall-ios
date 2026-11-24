//
//  INStartCallIntent+QuickStart.swift
//  QuickStartIntent
//
//  Created by Jaesung Lee on 2020/05/04.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

import Intents

extension INStartAudioCallIntent {
    var isValid: Bool { self.contacts?.first?.personHandle != nil }
}

extension INStartVideoCallIntent {
    var isValid: Bool { self.contacts?.first?.personHandle != nil }
}

@available(iOSApplicationExtension 13.0, *)
extension INStartCallIntent {
    var isValid: Bool { self.contacts?.first?.personHandle != nil }
}
