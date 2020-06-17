//
//  CallHistoryViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/29.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class CallHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var noHistoryIcon: UIImageView!
    @IBOutlet weak var noHistoryLabel: UILabel!
    @IBOutlet weak var darkView: UIView! {
        didSet { self.darkView.isHidden = true }
    }
    
    var query: DirectCallLogListQuery?
    var callHistories: [CallHistory]  = CallHistory.fetchAll()
    
    let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.delegate = self
        
        self.navigationItem.title = "Call History"
        
        // query
        let params = DirectCallLogListQuery.Params()
        params.limit = 100
        self.query = SendBirdCall.createDirectCallLogListQuery(with: params)
        
        guard self.callHistories.isEmpty else {
            self.tableView?.dataSource = self
            return
        }
        
        self.tableView?.isHidden = true
    
        self.indicator.startLoading(on: self.view)
        self.tableView?.dataSource = self
        self.fetchCallLogsFromServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateCallHistories()
    }
    
    // MARK: - Set Up Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.callHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView!.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! CallHistoryTableViewCell
        cell.delegate = self
        cell.callHistory = self.callHistories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView!.deselectRow(at: indexPath, animated: true)
        self.view.isUserInteractionEnabled = false  // This will back to true im dial completion handler
        let cell = tableView.cellForRow(at: indexPath) as! CallHistoryTableViewCell
        // make a same type of call: video / voice call
        self.didTapCallHistoryCell(cell)
    }
    
    // MARK: - Update Call Histories
    func fetchCallLogsFromServer() {
        // Get next call logs with query
        self.query?.next { callLogs, error in
            guard let newCallLogs = callLogs, !newCallLogs.isEmpty else {
                // Stop indicator animation when there is no more call logs.
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.indicator.stopLoading()
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Update callLogs
                let newHistories = newCallLogs.map { CallHistory(callLog: $0) }
                let previousSet = Set(self.callHistories)
                let newSet = Set(newHistories)
                let updateArray = previousSet.union(newSet).sorted(by: >)
                
                // Store to UserDefaults
                UserDefaults.standard.callHistories = updateArray
                
                // Update view based on stored data
                self.updateCallHistories()
            }
            // Keep fetching next call logs until there is no more
            self.fetchCallLogsFromServer()
        }
    }
    
    func updateCallHistories() {
        // Fetch stored histories
        self.callHistories = UserDefaults.standard.callHistories
        
        guard !self.callHistories.isEmpty else { return }
        self.tableView?.isHidden = false
        self.tableView?.reloadData()
    }
}

// MARK: - SendBirdCall: Make a Call
extension CallHistoryViewController: CallHistoryCellDelegate {
    // When select table view cell, make a call based on its `CallHistory` information.
    func didTapCallHistoryCell(_ cell: CallHistoryTableViewCell) {
        guard let remoteUserID = cell.remoteUserIDLabel.text else { return }
        let isVideoCall = cell.callHistory.hasVideo
        let dialParams = DialParams(calleeId: remoteUserID,
                                    isVideoCall: isVideoCall,
                                    callOptions: CallOptions(isAudioEnabled: true,
                                                             isVideoEnabled: isVideoCall,
                                                             localVideoView: nil,
                                                             remoteVideoView: nil,
                                                             useFrontCamera: true),
                                    customItems: [:])
        
        self.tableView?.isUserInteractionEnabled = false
        self.indicator.startLoading(on: self.view)
        
        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView?.isUserInteractionEnabled = true
                self.indicator.stopLoading()
                self.view.isUserInteractionEnabled = true
            }
            
            guard let call = call, error == nil else {
                DispatchQueue.main.async {
                    UIApplication.shared.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                }
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.showCallController(with: call)
            }
        }
    }
    
    // Make a voice call
    func didTapVoiceCallButton(with callHistory: CallHistory) {
        let callOptions = CallOptions(isAudioEnabled: true)
        let dialParams = DialParams(calleeId: callHistory.remoteUserID,
                                    isVideoCall: false,
                                    callOptions: callOptions,
        
                                    customItems: [:])
        self.tableView?.isUserInteractionEnabled = false
        self.indicator.startLoading(on: self.view)
        
        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView?.isUserInteractionEnabled = true
                self.indicator.stopLoading()
            }
            
            guard let call = call, error == nil else {
                DispatchQueue.main.async {
                    UIApplication.shared.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                }
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.showCallController(with: call)
            }
        }
    }
    
    // Make a video call
    func didTapVideoCallButton(with callHistory: CallHistory) {
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: true, localVideoView: nil, remoteVideoView: nil, useFrontCamera: true)
        let dialParams = DialParams(calleeId: callHistory.remoteUserID,
                                    isVideoCall: true,
                                    callOptions: callOptions,
                                    customItems: [:])
        
        self.tableView?.isUserInteractionEnabled = false
        self.indicator.startLoading(on: self.view)
        
        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView?.isUserInteractionEnabled = true
                self.indicator.stopLoading()
            }
            
            guard let call = call, error == nil else {
                DispatchQueue.main.async {
                    UIApplication.shared.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                }
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.showCallController(with: call)
            }
        }
    }
}
