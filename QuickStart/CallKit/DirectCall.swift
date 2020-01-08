//
//  DirectCall.swift
//  V2oIP
//
//  Created by Jaesung Lee on 2019/11/04.
//  Copyright © 2019 SendBird. All rights reserved.
//
import Foundation
import CallKit

/**
 User's Role
 
 - note: `getMyRole()`
 - Since: 1.0.0
 - Cases:
    - `none`: User has no role.
    - `caller`: User is a caller.
    - `callee`: User is a callee
 
 */
public enum UserRole {
    case caller, callee
}


/**
 EndType

 - Since: 1.0.0
 
 - Cases:
    - `none`
    - `end`
    - `cancel`
    - `decline`
    - `connectTimeout`
    - `reconnectTimeout`
    - `unknown`
 */
public enum EndType: String {
    case hangUp = "end"
    case cancel
    case decline
    case connectTimeout = "timeout"
    case reconnectTimeout = "reconnect_timeout"
    case unknown
}


class CallInfo {
    var isAudioCall: Bool
    
    var remoteConstraints: CallConstraints?
    
    var localConstraints: CallConstraints?
    
    init(isAudioCall: Bool = true, localConstraints: CallConstraints?, remoteConstraints: CallConstraints?) {
        self.isAudioCall = isAudioCall
        self.localConstraints = localConstraints
        self.remoteConstraints = remoteConstraints
    }
    
    // MARK: Caller
    convenience init(isAudioCall: Bool = true, localConstraints: CallConstraints) {
        self.init(isAudioCall: isAudioCall, localConstraints: localConstraints, remoteConstraints: nil)
    }
    
    // MARK: Callee
    convenience init(isAudioCall: Bool = true, remoteConstraints: CallConstraints) {
        self.init(isAudioCall: isAudioCall, localConstraints: nil, remoteConstraints: remoteConstraints)
    }
}




/**
 This class describes direct call.  It has an identifier as an unique key.
 
 - Since: 1.0.0
 */
public class DirectCall: BaseCall {
    
    /**
     Options in the call.
     
     e.g. isAudioEnabled
     */
    var callInfo: CallInfo
    
    /**
     My role of the call.  This property has `UserRole.none`as an initial value.
     */
    private var myRole: UserRole
    
    var turnCredential: TurnCredential?
    
    

//    var localVideoView: SendBirdView?
    
//    var remoteVideoView: SendBirdView!
    
    weak var delegate: CallDelegate?
    
    weak var callManager: CallManagerDataSource?
    
    /**
     Intializes the call for caller
     */
    convenience init(sender: CommandSender, callOptions: CallOptions) {
        self.init(state: IdleState(), sender: sender, myRole: .caller, caller: nil, callee: nil, isAudioCall: callOptions.isAudioCall, constraints: callOptions.constraints, turnCredential: nil)
    }
    
    /**
     Intializes the call for callee
     */
    convenience init(sender: CommandSender, callId: String, caller: User, callee: User, isAudioCall: Bool, constraints: CallConstraints, turnCredential: TurnCredential) {
        self.init(state: NoneState(), sender: sender, callId: callId, myRole: .callee, caller: caller, callee: callee, isAudioCall: isAudioCall, constraints: constraints, turnCredential: turnCredential)
    }
    
    private init(state: CallState, sender: CommandSender, callId: String = "", myRole: UserRole, caller: User?, callee: User?, isAudioCall: Bool, constraints: CallConstraints, turnCredential: TurnCredential?) {
        self.myRole = myRole
        self.callInfo = CallInfo(isAudioCall: isAudioCall, remoteConstraints: constraints)
        self.turnCredential = turnCredential
        
        super.init(callId: callId, state: state, sender: sender, caller: caller, callee: callee)
    }
    
    func didEnterEnding() {
        self.currentState.didEnterEndedEvent(call: self)
    }
}


// MARK: - Public Video Call
extension DirectCall {
//    public func startVideo() {
//        // TODO
//        guard let callOpts = self.callOptions else { return }
//        callOpts.constraints.video = true
//    }
//
//    public func muteVideo() {
//        guard let callOpts = self.callOptions else { return }
//        callOpts.constraints.audio = false
//    }
//
//    public func unmuteVideo() {
//        guard let callOpts = self.callOptions else { return }
//        callOpts.constraints.video = false
//    }
//
//    func switchCamera(completionHandler: CompletionHandler) {
//        // TODO
//        guard let callOpts = self.callOptions else { return }
//        callOpts.isCameraFront.toggle()
//    }
//
//    public func switchVideoView() {
//        // TODO
//    }
}


// MARK: - Public Audio Call
extension DirectCall {
    public func muteMicrophone() {
        // TODO
        guard var localConstraints = self.callInfo.localConstraints else { return }
        localConstraints.audio = true
    }
    
    public func unmuteMicrophone() {
        // TODO
        guard var localConstraints = self.callInfo.localConstraints else { return }
        localConstraints.audio = false
    }
}

// MARK: - EventDelegate
extension DirectCall: EventDelegate {
    /**
     Execute appropriate method concerned `CallEventCommand` received from `CallManager`
     
     - Since: 1.0.0
     */
    func didReceiveEvent(command: Command) {
        guard let event = command as? CallEventCommand else { return }
        
        switch event.commandType {
        case .accept:
            guard let acceptEvent = event as? AcceptEventCommand else { return }
            self.didReceiveAccept(command: acceptEvent)
        case .decline:
            guard let declineEvent = event as? DeclineEventCommand else { return }
            self.didReceiveDecline(command: declineEvent)
        case .cancel:
            self.currentState.didReceiveCancel(call: self)
        case .end:
            guard let endEvent = event as? EndEventCommand else { return }
            self.didReceiveEnd(command: endEvent)
        case .timeout:
            guard let timeoutEvent = event as? TimeoutEventCommand else { return }
            self.didReceiveTimeout(command: timeoutEvent)
        case .noAnswer:
            guard let noAnwerEvent = event as? NoAnswerEventCommand else { return }
            self.didReceiveNoAnswer(command: noAnwerEvent)
        case .offer:
            self.didReceiveOffer(command: event as! OfferEventCommand)
        case .answer:
            guard let answerEvent = event as? AnswerEventCommand else { return }
            self.didReceiveAnswer(command: answerEvent)
            
//        case .candidate:
//             self.currentState.didReceiveCandidate
            
        case .audio:
            guard var constraints = self.callInfo.remoteConstraints else { return }
            constraints.audio = (event as! AudioMuteEventCommand).isEnabled
        case .video:
            guard var constraints = self.callInfo.remoteConstraints else { return }
            constraints.video = (event as! VideoMuteEventCommand).isEnabled
        default: return
        }
    }
    
    func addEventDelegate(_ delegate: EventDelegate) {
//        self.
    }
}


// MARK: - Change State
extension DirectCall {
    
//
    
    /**
     This method changes the call state.
     
     - parameters:
        - nextState: `DirectCallState` object.
     - note:
        if `nextState` is `EstablishedState`, `callDidEnterEstablished()` will be exectued.
        if `nextState` is `ConnectedState`, `callDidEnterConnected()` will be executed.
     */
    func changeState(to nextState: CallState) {
        
        // self.currentState.deinit()
        self.currentState = nextState
    }
}
 
// MARK: - Dial
extension DirectCall {
    // MARK: - Dial
    /**
     - parameters:
        - userId: User ID as a `String` value.
        - callOptions: `CallOptions` object.
     */
    func dial(userId: String, callOptions: CallOptions, completionHandler: @escaping ErrorHandler) {
        self.currentState.dial(call: self, calleeId: userId, callOptions: callOptions, completionHandler: completionHandler)
    }
    
    func requestDial(calleeId: String, callOptions: CallOptions, completionHandler: @escaping ErrorHandler) {
        let dialRequest = DialRequest(calleeId: calleeId, isAudioCall: callOptions.isAudioCall, constraints: callOptions.constraints)
        
        self.sender.send(command: dialRequest) { response, error in
            guard let dialResponse = response as? DialResponse else {
                let error = SendBirdError(withCode: .ERR_UNKNOWN) // TODO: error
                self.currentState.didReceiveDialACK(call: self, error: error)
                completionHandler(error)
                return
            }
            
            self.callId = dialResponse.callId
            self.currentState.didReceiveDialACK(call: self, error: error)
            completionHandler(error)
        }
    }
    
    func didReceiveDial(command: DialEventCommand) {
        self.currentState.didReceiveDial(call: self)
    }
    
    public func cancel() {
        self.currentState.cancel(call: self)
    }
    
    func requestCancel() {
        let cancelRequest = CancelRequest(callId: self.callId)
        self.sender.send(command: cancelRequest) { response, error in
            // TODO: end info
        }
    }
    
    func didReceiveCancel(command: CancelEventCommand) {
        self.currentState.didReceiveCancel(call: self)
        
    }
}




    
// MARK: - Accept
extension DirectCall {
    // TODO: Completion X
    public func accept(callOptions: CallOptions) {
        self.currentState.accept(call: self, callOptions: callOptions)
    }
    
    func requestAccept(callOptions: CallOptions) {
        guard self.myRole == .callee else { return }
        
        self.callInfo.localConstraints = callOptions.constraints
        
        let acceptCommand = AcceptRequest(callId: self.callId, constraints: callOptions.constraints)   // TODO: constraintsÏCoj
        
        self.sender.send(command: acceptCommand) { response, error in
            guard let response = response as? AcceptResponse, response.isACK else {
                let error = SendBirdError(withCode: .ERR_UNKNOWN) // TODO: error
                self.currentState.didReceiveAcceptACK(call: self, error: error)
                return
            }
            
            self.currentState.didReceiveAcceptACK(call: self, error: error)
        }
    }
    
    func didReceiveAccept(command: AcceptEventCommand) {
        self.callInfo.remoteConstraints = command.constraints
        self.turnCredential = command.turnCredential
        self.currentState.didReceiveAccept(call: self)
    }
}








// MARK: - Decline
extension DirectCall {
    
    public func decline() {
        self.currentState.decline(call: self)
    }
    
    func requestDecline() {
        // TODO: request init parameter
        let declineRequest = DeclineRequest(callId: self.callId)
        self.sender.send(command: declineRequest) { response, error in
            guard let declineResponse = response as? DeclineResponse else { return }
            self.setEndInfo(with: declineResponse.endInfo)
        }
    }
    
    func didReceiveDecline(command: DeclineEventCommand) {
        self.setEndInfo(with: command.endInfo)
        self.currentState.didReceiveDecline(call: self)
    }
}




// MARK: - No Answer
extension DirectCall {
    func requestNoAnswer() {
        let naRequest = NoAnswerRequest(callId: self.callId)
        self.sender.send(command: naRequest) { response, error in
            guard let naResponse = response as? NoAnswerResponse else { return }
            self.setEndInfo(with: naResponse.endInfo)
        }
    }
    
    func didReceiveNoAnswer(command: NoAnswerEventCommand) {
        self.setEndInfo(with: command.endInfo)
        self.currentState.didReceiveNoAnswer(call: self)
    }
}



// MARK: - Offer & Answer
extension DirectCall {
    
    func offer() {
        let offerRequest = OfferRequest(callId: self.callId, sdp: "")   // SDP
        self.sender.send(command: offerRequest)
    }
    
    func didReceiveOffer(command: OfferEventCommand) {
        self.createRTCConnection()  // TODO: Business logic with WebRTC
//        command.sdp
        self.currentState.didReceiveOffer(call: self)
    }
    
    func answer() {
        let answerRequest = AnswerRequest(callId: self.callId, sdp: "") // TODO: SDP
        self.sender.send(command: answerRequest)
        
        self.createRTCConnection()
        self.currentState.didWebRTCConnected(call: self)
    }
    
    func didReceiveAnswer(command: AnswerEventCommand) {
        self.createRTCConnection()
        // command.sdp
        self.currentState.didWebRTCConnected(call: self)
    }
}



// MARK: - WebRTC Connection
extension DirectCall {
    
    func releaseResouces() {
//        guard let rtcConnection = self.rtcConnection else { return }
//        rtcConnection.close()
        self.currentState.didReleaseResource(call: self)
//        completionHandler?(nil) // TODO: do what?
    }
    
    func createRTCConnection() {
//        let rtcConnection = self.rtcConnection { // ... }
    }
}









// MARK: - End -> Closing
extension DirectCall {
    
    public func end() {
        // TODO
        self.currentState.end(call: self)
    }
    
    func requestEnd() {
        let endCommand = EndRequest(callId: self.callId)
        
        // TODO
        self.sender.send(command: endCommand) { response, error in
            guard let endResponse = response as? EndResponse else {
                // TODO
                print("[Failed to set EndInfo!]")
                return
            }
            self.setEndInfo(with: endResponse.endInfo)
        }
    }
    
    // TODO
    func didReceiveEnd(command: EndEventCommand) {
        self.setEndInfo(with: command.endInfo)
        self.currentState.didReceiveEnd(call: self)
    }
    
    
    
//    @objc
//    func run() {
//        self.currentState.timeOut(call: self)
//    }
//
    func timeout(with reason: TimeoutRequest.Reason) {
        let timeoutRequest = TimeoutRequest(callId: self.callId, reason: reason)
        self.sender.send(command: timeoutRequest)
    }
    
    func didReceiveTimeout(command: TimeoutEventCommand) {
        self.setEndInfo(with: command.endInfo)
        self.currentState.timeout(call: self)
    }
    
    func setEndInfo(with endInfo: EndInfo) {
        self.enderId = endInfo.ender.userId
        self.startedTimeStamp = endInfo.callStartTimestamp
        self.endedTimeStamp = endInfo.callEndTimestamp
        self.endType = EndType(rawValue: endInfo.reason) ?? .unknown
    }
    
//    func destroy(call: DirectCall, with endType: EndType, isCommandSent: Bool?, delegate: DestructionDelegate?) {
//        call.endType = endType
//
//        guard let isSent = isCommandSent, let delegate = delegate, endType == .unknown else {
//            self.destroy(call: call, isCommandSent: true, delegate: nil)
//            return
//        }
//
//        self.destroy(call: call, isCommandSent: isSent, delegate: delegate)
//    }
//
//    func destroy(call: DirectCall, isCommandSent: Bool, delegate: DestructionDelegate?) {
//    }
}





// MARK: - Set up Info
extension DirectCall {
    func setCallInfo(with command: DialEventCommand) {
        self.callId = command.callId
        self.callee = command.callee
        self.caller = command.caller
        self.callInfo.isAudioCall = command.isAudioCall
    }
    
    
    func setParticipant(with constraints: Data) {
        let dictionary = try? [String: Any](data: constraints)
        if let constDict = dictionary?["constraints"] as? [String: Any] {
            if self.myRole == .callee {
                guard let caller = self.caller else { return }
                caller.isVideoEnabled = (constDict["video"] as? Bool) ?? false
                caller.isAudioEnabled = (constDict["audio"] as? Bool) ?? false
            } else {
                guard let callee = self.callee else { return }
                callee.isVideoEnabled = (constDict["video"] as? Bool) ?? false
                callee.isAudioEnabled = (constDict["audio"] as? Bool) ?? false
            }
        }
    }
    
    func setParticipantVideoEnabled(with payload: [String: Any]) {
        if let isEnabled = payload["is_enabled"] as? Bool {
            if self.myRole == .callee {
                guard let caller = self.caller else { return }
                caller.isAudioEnabled = isEnabled
            } else {
                guard let callee = self.callee else { return }
                callee.isAudioEnabled = isEnabled
            }
        }
    }
}







// TODO: CallKit
//
//import UIKit
//
//extension DirectCall {
//    func showRinging(on viewController: UIViewController & CXProviderDelegate) {
//        let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "My App"))
//        provider.setDelegate(viewController, queue: nil)
//
//        let update = CXCallUpdate()
//        update.remoteHandle = CXHandle(type: .generic, value: self.caller!.userId)
//        provider.reportNewIncomingCall(with: UUID(uuidString: self.callId)!, update: update, completion: { error in })
//    }
//
//    func showDialing(on viewController: UIViewController & CXProviderDelegate) {
//        let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: SendBirdCall.shared.appName ?? "SendBirdCall"))
//        provider.setDelegate(viewController, queue: nil)
//
//        let controller = CXCallController()
//        let transaction = CXTransaction(action: CXStartCallAction(call: UUID(uuidString: self.callId)!, handle: CXHandle(type: .generic, value: "You are calling \(self.callee!.userId)")))
//        controller.request(transaction, completion: { error in })
//
//    }
//}
