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
        guard let urlString = urlString else { return }
        guard let profileURL = URL(string: urlString) else { return }
        self.load(from: profileURL)
        
        
//        guard let profileURL = NSURL(string: urlString) else { return }
//
//        // update
//        ImageCache.shared.load(url: profileURL) { image in
//            guard let image = image, image != self.image else { return }
//
//            // Update image only when it's needed, run on custom queue asynchrouns.
//            let queue = DispatchQueue(label: "com.sendbird.calls.quickstart.image.update")
//            queue.async {
//                self.image = image
//            }
//        }
    }
    
    func load(from url: URL) {
        let cache = URLCache.shared
        let imgRequest = URLRequest(url: url)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = cache.cachedResponse(for: imgRequest)?.data,
                let image = UIImage(data: data) {
                DispatchQueue.main.async() { [weak self] in
                    guard let self = self else { return }
                    self.image = image
                }
            } else {
                URLSession.shared.dataTask(with: imgRequest) { [weak self] data, response, error in
                    guard let self = self else { return }
                    guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
//                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    let cacheData = CachedURLResponse(response: httpURLResponse, data: data)
                    cache.storeCachedResponse(cacheData, for: imgRequest)

                    DispatchQueue.main.async() { [weak self] in
                        guard let self = self else { return }
                        guard image != self.image else { return }
                        self.image = image
                        self.layoutIfNeeded()
                    }
                }.resume()
            }
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
    private var loadingResponses: [NSURL: [imageHandler]] = [:]
    
    func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    func load(url: NSURL, completionHandler: @escaping ((UIImage?) -> ())) {
        
        // If there is cached image, return immediately.
        if let cachedImage = image(url: url) {
            completionHandler(cachedImage)
            return
        }
        
        guard loadingResponses[url] == nil else {
            loadingResponses[url]?.append(completionHandler)
            return
        }
        loadingResponses[url] = [completionHandler]
        
        // Request to fetch the image
        ImageURLProtocol.urlSession.dataTask(with: url as URL) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data, let image = UIImage(data: data),
                let blocks = self.loadingResponses[url], error == nil else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                    return
            }
            
            // Cache the image
            self.cachedImages.setObject(image, forKey: url, cost: data.count)
            
            // Iterate over each requestor for the image and pass it back
            blocks.forEach { block in
                DispatchQueue.main.async {
                    block(image)
                }
            }
        }.resume()
    }
}

class ImageURLProtocol: URLProtocol {
    var isDone: Bool = false
    var block: DispatchWorkItem!
    
    private static let queue = DispatchQueue(label: "com.sendbird.calls.quickstart.imageurl.protocol")
    
    static var urlSession: URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ImageURLProtocol.classForCoder()]
        return  URLSession(configuration: config)
    }
    
    override class func canInit(with request: URLRequest) -> Bool { return true }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool { return false }
    
    override func startLoading() {
        guard let urlRequest = request.url, let urlClient = client else { return }
        
        self.block = DispatchWorkItem(block: { [weak self] in
            guard let self = self else { return }
            guard self.isDone == false else { return }
            let fileURL = URL(fileURLWithPath: urlRequest.path)
            if let data = try? Data(contentsOf: fileURL) {
                urlClient.urlProtocol(self, didLoad: data)
                urlClient.urlProtocolDidFinishLoading(self)
            }
            self.isDone = true
        })
        
        ImageURLProtocol.queue.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500 * NSEC_PER_MSEC), execute: block)
    }
    
    override func stopLoading() {
        ImageURLProtocol.queue.async { [weak self] in
            guard let self = self else { return }
            guard let cancelBlock = self.block, self.isDone == false else { return }
            cancelBlock.cancel()
            self.isDone = true
        }
    }
    
}
