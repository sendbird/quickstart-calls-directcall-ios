//
//  UIImageView+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UIImageView {
    func rounding() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
    
    func border() {
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.QuickStart.lightPurple.cgColor
    }
    
    func setImage(urlString: String?) {
        DispatchQueue.global().async {
            guard let urlString = urlString,
                let profileURL = URL(string: urlString) else { return }
            guard let data = try? Data(contentsOf: profileURL) else { return }
            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else { return }
                self.image = image
            }
        }
    }
}
