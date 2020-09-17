//
//  SendBirdCredential.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/08/07.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation
import UIKit


class CredentialManager {
    // Singleton
    static let shared = CredentialManager()
    private static let urlScheme = "sendbird://"
    
    private var delegates: NSMapTable<NSString, AnyObject>    // weak map
    
    init() {
        self.delegates = NSMapTable(keyOptions: .strongMemory, valueOptions: .weakMemory)
    }
    
    func addDelegate(_ delegate: CredentialDelegate, forKey key: String) {
        self.delegates.setObject(delegate, forKey: key as NSString)
    }
    
    /// Updates credential in `UserDefaults` and invoke delegate method
    func updateCredential(_ credential: Credential?) {
        UserDefaults.standard.credential = credential
        DispatchQueue.main.async {
            self.delegates
                .objectEnumerator()?
                .compactMap({ $0 as? CredentialDelegate })
                .forEach({ $0.didUpdateCredential(credential) })
        }
    }
    
    /// Handle URL scheme containg `sendbird://` as a prefix and signs in.
    ///  - Parameters:
    ///     - url: URL from URL scheme.
    /// - Returns: The boolean value indicating whether the url is valid or not.
    func handle(url: URL) throws -> Credential {
        return try self.decode(url: url)
    }
    
    /// Handle data from QR code and signs in.
    /// - Parameters:
    ///     - qrData: The data from QR code.
    ///     - completion: The completion handler that allows you to handle the result.
    func handle(qrData: Data) throws -> Credential {
        // Decoding
        return try self.decode(base64EncodedData: qrData)
    }
    
    /// Take `Data` object and reture result
    private func decode(base64EncodedData data: Data) throws -> Credential {
        return try JSONDecoder().decode(Credential.self, from: data)
    }
    
    private func decode(url: URL) throws -> Credential {
        let stringValue = url.absoluteString.replacingOccurrences(of: CredentialManager.urlScheme, with: "")
        guard let data = Data(base64Encoded: stringValue) else { throw CredentialErrors.invalidURL }
        return try self.decode(base64EncodedData: data)
    }
}
