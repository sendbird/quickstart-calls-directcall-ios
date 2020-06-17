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
        guard let urlString = urlString, !urlString.isEmpty else {
            self.image = UIImage(named: "iconAvatar")
            return
        }
        guard let profileURL = URL(string: urlString) else { return }
        
        ImageCache.shared.load(url: profileURL) { image, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Failed to load image")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // If returned image is same as current image
                guard self.image != image else { return }
                self.image = image
                self.layoutIfNeeded()
            }
        }
    }
}

extension UIImage {
    enum CallDirection {
        case outgoing(_ type: CallType)
        case incoming(_ type: CallType)
        
        enum CallType {
            case voiceCall
            case videoCall
        }
    }
    
    static func callTypeImage(outgoing: Bool, hasVideo: Bool) -> UIImage? {
        let type: CallDirection.CallType = hasVideo ? .videoCall : .voiceCall
        let direction: CallDirection = outgoing ? .outgoing(type) : .incoming(type)
        switch direction {
            case .outgoing(.voiceCall):
                return UIImage(named: "iconCallVoiceOutgoingFilled")
            case .outgoing(.videoCall):
                return UIImage(named: "iconCallVideoOutgoingFilled")
            case .incoming(.voiceCall):
                return UIImage(named: "iconCallVoiceIncomingFilled")
            case .incoming(.videoCall):
                return UIImage(named: "iconCallVideoIncomingFilled")
        }
    }
}


