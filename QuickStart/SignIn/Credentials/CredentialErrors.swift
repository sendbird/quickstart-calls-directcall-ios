//
//  CredentialErrors.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/09/17.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

/// The errors that can be occurred while trying to authenticate
enum CredentialErrors: String, Error {
    case empty = "There is no stored credential."
    case noUserID = "Please enter your ID and your name."
    case unknown = "Something went wrong. Try again."
    case alreadyAuthenticated = "Couldn’t sign you in. If you’re already using the app, sign out first."
    case invalidURL = "Invalid URL."
    
    var localizedDescription: String { self.rawValue }
}
