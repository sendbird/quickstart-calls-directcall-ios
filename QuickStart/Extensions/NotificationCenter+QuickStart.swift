//
//  NotificationCenter+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.//

import UIKit

extension NotificationCenter {
    static func observeKeyboard(showAction actionAfterKeyboardShow: Selector,
                                hideAction actionBeforeKeyboardHide: Selector,
                                target viewController: UIViewController) {
        NotificationCenter.default.addObserver(viewController, selector: actionAfterKeyboardShow, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(viewController, selector: actionBeforeKeyboardHide, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
}
