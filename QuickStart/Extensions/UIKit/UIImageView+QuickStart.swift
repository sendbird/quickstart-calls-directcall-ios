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
    
    func updateImage(urlString: String?) {
        guard let urlString = urlString else { return }
        guard let profileURL = URL(string: urlString) else { return }
        
        ImageCache.shared.load(url: profileURL) { image, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Failed to load image")
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.image = image
                self.layoutIfNeeded()
            }
        }
    }
}


