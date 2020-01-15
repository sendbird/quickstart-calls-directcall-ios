//
//  UIViewController+QuickStart.swift
//  SendBirdCall Tester
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    static var topViewController: UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
    
    func alertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let actionDone = UIAlertAction(title: "Done", style: .cancel)
        alert.addAction(actionDone)
        self.present(alert, animated: true, completion: nil)
    }
}
