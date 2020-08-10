//
//  SignInDelegate.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/23.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

protocol SignInDelegate: class {
    func didSignIn(credential: SendBirdCredentialManager.SendBirdCredential)
}
