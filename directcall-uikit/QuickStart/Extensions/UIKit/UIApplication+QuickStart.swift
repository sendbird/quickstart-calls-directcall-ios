//
//  UIApplication+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/13.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

extension UIApplication {
    /// Screens to show when the app's window becomes ready. See `showWhenWindowIsReady(_:)`.
    private static var pendingScreens: [(UIWindow) -> Void] = []

    /// Shows a screen with the app's window now, or when the app's scene becomes active if there is no window yet.
    ///
    /// With the scene life cycle, the app can run without a window, for example when an incoming call launched it
    /// in the background and the user answered on the lock screen. `SceneDelegate` calls `showPendingScreens()`.
    func showWhenWindowIsReady(_ show: @escaping (UIWindow) -> Void) {
        if let window = keyWindow {
            show(window)
        } else {
            Self.pendingScreens.append(show)
        }
    }

    func showPendingScreens() {
        guard let window = keyWindow else { return }
        let screens = Self.pendingScreens
        Self.pendingScreens = []
        screens.forEach { $0(window) }
    }

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
            
            self.showWhenWindowIsReady { window in
                // The call may have ended while the app had no window.
                guard !call.isEnded else { return }
                if let topViewController = UIViewController.topViewController {
                    topViewController.present(viewController, animated: true, completion: nil)
                } else {
                    window.rootViewController = viewController
                    window.makeKeyAndVisible()
                }
            }
        }
    }
    
    func showError(with errorDescription: String?) {
        let message = errorDescription ?? "Something went wrong. Please retry."
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showWhenWindowIsReady { window in
                if let topViewController = UIViewController.topViewController {
                    topViewController.presentErrorAlert(message: message)
                } else {
                    window.rootViewController?.presentErrorAlert(message: message)
                    window.makeKeyAndVisible()
                }
            }
        }
    }
}
