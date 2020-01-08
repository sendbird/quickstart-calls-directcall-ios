//
//  NotificationCenter+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.//

import UIKit

//class SBKeyboard {
//    static func addObserver(action1 actionAfterKeyboardShow: Selector, action2 actionBeforeKeyboardHide: Selector, on viewController: UIViewController) {
//    }
//}
//
extension NotificationCenter {
    static func observeKeyboard(action1 actionAfterKeyboardShow: Selector, action2 actionBeforeKeyboardHide: Selector, on viewController: UIViewController) {
        NotificationCenter.default.addObserver(viewController, selector: actionAfterKeyboardShow, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(viewController, selector: actionBeforeKeyboardHide, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
}
