//
//  UIStoryboard+QuickStart.swift
//  QuickStart
//
//  Created by Damon Park on 2020/03/26.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

extension UIStoryboard {
    private static var main: UIStoryboard { UIStoryboard.init(name: "Main", bundle: nil) }
    
    private static var signIn: UIStoryboard { UIStoryboard.init(name: "SignIn", bundle: nil) }
    
    fileprivate enum QuickStart: String {
        case simpleSignIn = "SignInViewController"
        case signIn = "SignInWithQRViewController"
        case videoCall = "VideoCallViewController"
        case voiceCall = "VoiceCallViewController"
        
        private var storyboard: UIStoryboard {
            switch self {
                case .simpleSignIn: return .signIn
                case .signIn: return .signIn
                case .videoCall: return .main
                case .voiceCall: return .main
            }
        }
        
        var controller: UIViewController {
            self.storyboard.instantiateViewController(withIdentifier: self.rawValue)
        }
    }
}

extension UIStoryboard {
    static func signController() -> UIViewController {
        let hasConfiguredAppId = (UserDefaults.standard.credential?.appId != nil || UserDefaults.standard.designatedAppId != nil)
        let controller = (hasConfiguredAppId ? QuickStart.simpleSignIn : QuickStart.signIn).controller
        if #available(iOS 13.0, *) {
            controller.isModalInPresentation = true
        }
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
    
    static func callController(_ isVideoCall: Bool) -> UIViewController {
        let controller = (isVideoCall ? QuickStart.videoCall : QuickStart.voiceCall).controller
        if #available(iOS 13.0, *) {
            controller.isModalInPresentation = true
        }
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
