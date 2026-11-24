//
//  UIButton+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UIButton {
    func rounding() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
    
    func setupAudioOption(isOn: Bool) {
        self.setTitleColor(.purple, for: .normal)
        let title = isOn ? "Mute Audio" : "Unmute Audio"
        self.setTitle(title, for: .normal)
    }
    
    func smoothAndWider() {
        self.layer.cornerRadius = self.frame.height / 4
        self.layer.masksToBounds = true

        self.backgroundColor = .purple
    }
    
    func setTitle(_ title: String) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.textAlignment = .center
    }
}
