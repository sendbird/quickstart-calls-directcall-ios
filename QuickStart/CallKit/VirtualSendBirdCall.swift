//
//  VirtualSendBirdCall.swift
//  SendBirdCall Tester
//
//  Created by Jaesung Lee on 2019/11/27.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit

public typealias AuthenticateHandler = (_ user: User?, _ error: Error?) -> Void

typealias CallHandler = (_ call: BaseCall?, _ error: Error?) -> Void

typealias ErrorHandler = (_ error: Error?) -> Void

typealias CommandHandler = (_ command: Command?, _ error: Error?) -> Void

typealias StringHandler = (_ string: String?, _ error: Error?) -> Void

typealias AckHandler = (_ data: Data?, _ error: Error?) -> Void

typealias VoidHandler = () -> Void


public class SendBirdCall {
    
    internal static var main = SendBirdCall()

    private static var completionHandlerAndDelegateQueue: DispatchQueue = DispatchQueue.main    // TODO:
        
    public static var appId: String?
    
    /**
     Authenticates user with user ID and Access Token that you generated at SendBird Dashboard.
     
     - parameters:
        - userId: User ID
        - accessToken: Access Token
        - deviceToken: Device Token
        - completionHandler: The handler to call when the authenication is complete.
     */
    public static func authenticate(userId: String, accesssToken: String? = nil, deviceToken: String? = nil, completionHandler: @escaping AuthenticateHandler) {
        self.main.authenticate(userId: userId, accesssToken: accesssToken, deviceToken: deviceToken, completionHandler: completionHandler)
    }
    
    public static func addDelegate(identifier: String, delegate: SendBirdCallDelegate) {
        self.main.addDelegate(identifier: identifier, delegate: delegate)
    }
    
    public static func removeDelegate(identifier: String) {
        self.main.removeDelegate(identifier: identifier)
    }
    
    /**
     Calls to user(callee) directly.
     
     - Returns: `DirectCall` object
     */
    @discardableResult static func dial(calleeId: String, callOptions: CallOptions) -> DirectCall {
        return self.main.dial(calleeId: calleeId, callOptions: callOptions)
    }
    
    static func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        self.main.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
}

