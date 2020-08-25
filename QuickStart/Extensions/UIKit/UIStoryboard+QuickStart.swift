//
//  UIStoryboard+QuickStart.swift
//  QuickStart
//
//  Created by Damon Park on 2020/03/26.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit

extension UIStoryboard {
    private static var main: UIStoryboard { UIStoryboard.init(name: "Main", bundle: nil) }
    
    private static var signIn: UIStoryboard { UIStoryboard.init(name: "SignIn", bundle: nil) }
    
    fileprivate enum QuickStart: String {
        case signIn = "SignInViewController"
        case videoCall = "VideoCallViewController"
        case voiceCall = "VoiceCallViewController"
        
        var controller: UIViewController {
            switch self {
                case .signIn: return UIStoryboard.signIn.instantiateViewController(withIdentifier: self.rawValue)
                default: return UIStoryboard.main.instantiateViewController(withIdentifier: self.rawValue)
            }
        }
    }
}

extension UIStoryboard {
    static func signController() -> UIViewController {
        QuickStart.signIn.controller
    }
    
    static func callController(_ isVideoCall: Bool) -> UIViewController {
        (isVideoCall ? QuickStart.videoCall : QuickStart.voiceCall).controller
    }
}
