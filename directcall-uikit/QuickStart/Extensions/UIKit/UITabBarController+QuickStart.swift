//
//  UITabBarController+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/05/07.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

import UIKit

extension UITabBarController {
    var callHistoryTab: UINavigationController? { self.viewControllers?[1] as? UINavigationController }
}

extension UINavigationController {
    var firstViewController: UIViewController? { self.viewControllers.first }
}
