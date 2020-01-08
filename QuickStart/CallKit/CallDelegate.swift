//
//  CallDelegate.swift
//  V2oIP
//
//  Created by Jaesung Lee on 2019/11/04.
//  Copyright © 2019 SendBird. All rights reserved.
//

public protocol CallDelegate: class {
    // TODO : DirectCall -> BaseCall???
    func didEstablish(_ call: DirectCall)
    
    func didConnect(_ call: DirectCall)
    
    func didStartReconnecting(_ call: DirectCall)
    
    func didReconnect(_ call: DirectCall)
    
    func call(_ call: BaseCall, didEnableRemoteVideo isEnabled: Bool)
    
    func call(_ call: BaseCall, didEnableRemoteAudio isEnabled: Bool)
    
    func didEnd(_ call: DirectCall)
}
