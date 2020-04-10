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
        guard let profileURL = NSURL(string: urlString) else { return }
        
        ImageCache.shared.load(url: profileURL) { [weak self] image in
            guard let self = self else { return }
            guard let image = image else { return }
            self.image = image
        }
    }
}

extension UIImage {
    static var mutedAudioImage: UIImage? {
        get {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "mic.slash.fill")
            } else {
                return UIImage(named: "icon_audio_mute")
            }
        }
    }
    
    static var unmutedAudioImage: UIImage? {
        get {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "mic.fill")
            } else {
                return UIImage(named: "icon_audio_unmute")
            }
        }
    }
}

class ImageCache {
    typealias imageHandler = ((UIImage?) -> ())
    
    static let shared = ImageCache()
    
    private let cachedImages = NSCache<NSURL, UIImage>()
    
    private func cachedImage(from url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    func load(url: NSURL, completion: @escaping imageHandler) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // If there is cached image, return immediately.
            if let cachedImage = self.cachedImage(from: url) {
                DispatchQueue.main.async { completion(cachedImage) }
                return
            }
            
            let imageRequest = URLRequest(url: url as URL)
            URLSession.shared.dataTask(with: imageRequest) { [weak self] data, response, error in
                guard let self = self else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                // Check im
                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let data = data, let image = UIImage(data: data),
                    error == nil else {
                        DispatchQueue.main.async { completion(nil) }
                        return
                }
                
                // Cache and return loaded image
                self.cachedImages.setObject(image, forKey: url)
                DispatchQueue.main.async { completion(image) }
                
            }.resume()
        }
    }
}
