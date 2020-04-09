//
//  AppDelegate+Intent.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/08.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import CallKit
import SendBirdCalls

// This extension is for outgoing call from outside the app.
extension AppDelegate {
    
    // MARK: - From URL
    // To make an outgoing call from url, you need to implement this method
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let calleeId = url.calleeId else { return false }
        
        guard SendBirdCall.currentUser == nil else {
            self.dial(to: calleeId, hasVideo: false)
            return true
        }
        
        let userId = UserDefaults.standard.user.id
        let accessToken = UserDefaults.standard.accessToken
        if userId.isEmpty { return false }
        
        let authParams = AuthenticateParams(userId: userId, accessToken: accessToken)
        SendBirdCall.authenticate(with: authParams) { [weak self] user, error in
            guard let self = self else { return }
            guard error == nil else {
                DispatchQueue.main.async { [ weak self] in
                    guard let self = self else { return }
                    self.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                }
                return
            }
            self.dial(to: calleeId, hasVideo: false)
        }
        return true
    }
    
    // MARK: - From Native Call Logs
    // To make an outgoing call from native call logs, so called "Recents" in iPhone, you need to implement this method and add IntentExtension as a new target.
    // Please refer to IntentHandler (path: ~/QuickStartIntent/IntentHandler.swift)
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let calleeId = userActivity.calleeId else {
            showError(with: "Could not determine callee ID")
            return false
        }
        
        guard let hasVideo = userActivity.hasVideo else {
            showError(with: "Could not determine video from call log")
            return false
        }
        
        guard SendBirdCall.currentUser == nil else {
            self.dial(to: calleeId, hasVideo: hasVideo)
            return true
        }
        
        let userId = UserDefaults.standard.user.id
        let accessToken = UserDefaults.standard.accessToken
        guard !userId.isEmpty else { return false }
        
        let authParams = AuthenticateParams(userId: userId, accessToken: accessToken)
        SendBirdCall.authenticate(with: authParams) { [weak self] user, error in
            guard let self = self else { return }
            guard error == nil else {
                DispatchQueue.main.async { [ weak self] in
                    guard let self = self else { return }
                    self.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                }
                return
            }
            self.dial(to: calleeId, hasVideo: hasVideo)
        }
        return true
    }
    
    // MARK: - Actions
    
    private func dial(to calleeId: String, hasVideo video: Bool) {
        let callOption = CallOptions(isAudioEnabled: true, isVideoEnabled: video, localVideoView: nil, remoteVideoView: nil, useFrontCamera: true)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: video, callOptions: callOption, customItems: [:])
        SendBirdCall.dial(with: dialParams) { call, error in
            guard let call = call, error == nil else {
                DispatchQueue.main.async { [ weak self] in
                    guard let self = self else { return }
                    self.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                }
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.showCallView(call, hasVideo: call.isVideoCall)
            }
        }
    }
    
    private func showCallView(_ call: DirectCall, hasVideo: Bool) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: call.isVideoCall ? "VideoCallViewController" : "VoiceCallViewController")

        if var dataSource = viewController as? DirectCallDataSource {
            dataSource.call = call
            dataSource.isDialing = true
        }
        
        if let topViewController = UIViewController.topViewController {
            topViewController.present(viewController, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
    }
    
    private func showError(with message: String) {
        if let topViewController = UIViewController.topViewController {
            topViewController.presentErrorAlert(message: message)
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.presentErrorAlert(message: message)
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
    }
}
