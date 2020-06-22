//
//  UIApplication+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/13.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

extension UIApplication {
    func showCallController(with call: DirectCall) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // If there is termination: Failed to load VoiceCallViewController from Main.storyboard. Please check its storyboard ID")
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: call.isVideoCall ? "VideoCallViewController" : "VoiceCallViewController")
            
            if var dataSource = viewController as? DirectCallDataSource {
                dataSource.call = call
                dataSource.isDialing = false
            }
            
            if let topViewController = UIViewController.topViewController {
                topViewController.present(viewController, animated: true, completion: nil)
            } else {
                self.keyWindow?.rootViewController = viewController
                self.keyWindow?.makeKeyAndVisible()
            }
        }
    }
    
    func showError(with message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let topViewController = UIViewController.topViewController {
                topViewController.presentErrorAlert(message: message)
            } else {
                self.keyWindow?.rootViewController?.presentErrorAlert(message: message)
                self.keyWindow?.makeKeyAndVisible()
            }
        }
    }
}
