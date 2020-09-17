//
//  CredentialDelegate.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/09/17.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

protocol CredentialDelegate: class {
    func didUpdateCredential(_ credential: Credential?)
}
