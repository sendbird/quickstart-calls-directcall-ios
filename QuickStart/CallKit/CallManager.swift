//
//  CallManager.swift
//  V2oIP
//
//  Created by Jaesung Lee on 2019/11/04.
//  Copyright © 2019 SendBird. All rights reserved.
//
import Foundation

protocol CallManagerDataSource: class {
    func remove(_ call: DirectCall)
}

class CallManager {
    private var sender: CommandSender
    
    var calls: [String : DirectCall] = [:]
        
    init(sender: CommandSender) {
        self.sender = sender
    }
        
    // MARK: - Calls
    func add(call: DirectCall) {
        self.calls.updateValue(call, forKey: call.callId)
        print("[CallManager] \(#function) callId: \(call.callId)")
    }
    
    /**
     Removes all calls.
     */
    func removeAllCalls() {
        self.calls.removeAll()
    }
    
}

extension CallManager {
    func dial(calleeId: String, callOptions: CallOptions) -> DirectCall {
        let call = DirectCall(sender: self.sender, callOptions: callOptions)
        
        call.dial(userId: calleeId, callOptions: callOptions) { error in
            if error == nil {
                self.add(call: call)
                self.broadcastEnteredDialing(call: call)
            }
        }
        
        return call
    }
    
    
    // TODO
    func didReceiveDial(command: Command) {
        guard let dialCommand = command as? DialEventCommand else {
            return
        }
        
        let call = DirectCall(sender: self.sender,
                              callId: dialCommand.callId,
                              caller: dialCommand.caller,
                              callee: dialCommand.callee,
                              isAudioCall: dialCommand.isAudioCall,
                              constraints: dialCommand.constraints,
                              turnCredential: dialCommand.turnCredential)
        self.add(call: call)
        call.didReceiveDial(command: dialCommand)
        
        self.broadcastEnteredDialed(call: call)
    }
    
    func broadcastEnteredDialed(call: DirectCall) {
        // TODO:
    }
    
    func broadcastEnteredDialing(call: DirectCall) {
        // TODO:
    }
}

extension CallManager: CallManagerDataSource {
    
    
    /**
     Removes `DirectCall` object with its call ID.
     
     - parameters:
     - call: `DirectCall` object that you want to remove.
     */
    func remove(_ call: DirectCall) {
        self.calls.removeValue(forKey: call.callId)
        print("[CallManager] \(#function) calls value has been \(calls)")
    }
}

extension CallManager: EventDelegate {
    func didReceiveEvent(command: Command) {
        guard let event = command as? CallEventCommand else { return }
        
        if event.commandType == .dial {
            self.didReceiveDial(command: command)
        } else {
            guard let call = self.calls[event.callId] else {
                print("There is no call for the command")
                return
            }
            call.didReceiveEvent(command: event)
        }
    }
}
