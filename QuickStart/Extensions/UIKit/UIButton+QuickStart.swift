//
//  UIButton+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
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
    
    func smoothAndWider(title: String) {
        self.layer.cornerRadius = self.frame.height / 4
        self.layer.masksToBounds = true

        self.backgroundColor = .purple

        self.titleLabel?.text = title
        self.titleLabel?.textColor = .white
        self.titleLabel?.textAlignment = .center
    }
}
