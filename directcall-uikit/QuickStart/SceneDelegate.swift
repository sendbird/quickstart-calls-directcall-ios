//
//  SceneDelegate.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import UIKit

/// Shows the app in a window scene.
///
/// Apps built with the iOS 27 SDK must use the scene life cycle. The `UIApplicationSceneManifest` in `Info.plist`
/// names this class and `Main.storyboard`, so UIKit creates the window and loads the storyboard for the scene.
///
/// With the scene life cycle, `sendbird://` URLs and calls from the Phone app's Recents arrive here,
/// not at `application(_:open:options:)` or `application(_:continue:restorationHandler:)` of the app delegate.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var appDelegate: AppDelegate? { UIApplication.shared.delegate as? AppDelegate }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // The URL or the Recents call that launched the app.
        if let url = connectionOptions.urlContexts.first?.url {
            appDelegate?.handle(url: url)
        }
        if let userActivity = connectionOptions.userActivities.first {
            appDelegate?.handle(userActivity: userActivity)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // The app can run before this window exists, for example when an incoming call launched it in the background.
        // Show the screens it asked for meanwhile, such as the call screen or the sign-in screen.
        UIApplication.shared.showPendingScreens()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        appDelegate?.handle(url: url)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        appDelegate?.handle(userActivity: userActivity)
    }
}
