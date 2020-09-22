//
//  Int+QuickStart.swift
//  QuickStart
//
//  Created by Damon Park on 2020/03/27.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

extension Int64 {
    func currentTimerText() -> String {
        let duration = self
        
        let convertedTime = Int(duration / 1000)
        let hour = Int(convertedTime / 3600)
        let minute = Int(convertedTime / 60) % 60
        let second = Int(convertedTime % 60)
        
        // update UI
        var timeText = [String]()
        
        if hour > 0 { timeText.append(String(hour)) }
        timeText.append(String(format: "%02d", minute))
        timeText.append(String(format: "%02d", second))
        
        return timeText.joined(separator: ":")
    }
    
    func durationText() -> String {
        let duration = self
        
        let convertedTime = Int(duration / 1000)
        let hour = Int(convertedTime / 3600)
        let minute = Int(convertedTime / 60) % 60
        let second = Int(convertedTime % 60)
        
        // update UI
        var timeText = [String]()
        
        if hour > 0 { timeText.append(String(hour) + "h") }
        if minute > 0 { timeText.append(String(format: "%02d", minute) + "m") }
        timeText.append(String(format: "%02d", second) + "s")
        
        return timeText.joined(separator: " ")
    }
}
