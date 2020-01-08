//
//  BaseCall.swift
//  V2oIP
//
//  Created by Jaesung L ee on 2019/11/04.
//  Copyright © 2019 SendBird. All rights reserved.
//

/**
 This class sends `CommandSender` object to `CommandRouter` when `DirectCall` do something.
 
 - properties:
    - sender: `Command Sender` object.
    - callId: Call ID
    - caller: `User` optional object.
    - callee: `User` optional object.
    - currentState:  State object that adopts and conforms to the `CallState` protocol.
    
 */
public class BaseCall {
    // MARK: - Sender
    /**
     This property sends command.
     */
    var sender: CommandSender
    
    
    // MARK: - Call Info
    /**
     Call Identifier.
     
     - note:
     When a callee received dial, the call ID must have value, so it doesn't need to be declared as an optional.
     Until server respond to `START CALL`, call ID has had initialized value as an empty string.
     */
    public var callId: String
    
    
    /**
     The caller's object. It can be used for showing the caller's name on the screen of the callee.
     */
    public var caller: User?
    
    
    /**
     The callee's object.  It can be used for showing the callee's name on the screen of the caller.
     */
    public var callee: User?
    
    
    // MARK: - End Info
    /**
     Ender ID.  This property has initialized value of `String`
     */
    public var enderId: String?
    
    
    /**
     Type of ending call.  This property has `EndType.none` as an initial value.
     */
    public var endType: EndType?
    
    
    /**
     The started time of call.  This property has a 64bit unsigned integer type.
     */
    public var startedTimeStamp: Int64?
    
    
    /**
    The ended time of call.  This property has a 64bit unsigned integer type.
    */
    public var endedTimeStamp: Int64?
    
    
    // MARK: - State
    /**
     A current state of the call.
     
     - Important: Intial state is `Idle`  as `IdleState`
     
     - Note:
     Caller's state: `Idle` -> `Dialing` -> `Established` -> `Offering` -> `Connected` -> `Ended`
     Callee's state: `Idle` -> `Ringing` -> `Established` -> `Offered` -> `Connected` -> `Ended`
     */
    var currentState: CallState
    
    
    // MARK: - Methods
    convenience init(sender: CommandSender) {
        self.init(state: IdleState(), sender: sender, caller: nil, callee: nil)
    }
    
    init(callId: String = "", state: CallState, sender: CommandSender, caller: User?, callee: User?) {
        self.callId = callId
        self.currentState = state
        
        self.sender = sender
        
        self.caller = caller
        self.callee = callee
    }
    
    func update(caller: User, callee: User) {
        self.caller = caller
        self.callee = callee
    }
    
    private enum CodingKeys: String, CodingKey {
        case callId = "call_id"
        case caller = "caller"
        case callee = "callee"
    }
}
