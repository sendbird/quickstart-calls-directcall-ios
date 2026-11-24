//
//  CredentialDelegate.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/09/17.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

protocol CredentialDelegate: class {
    /// Called when a current credential was updated.
    /// - Parameters:
    ///     - credential: An updated `Credential` object. It's optional type.
    func didUpdateCredential(_ credential: Credential?)
}
