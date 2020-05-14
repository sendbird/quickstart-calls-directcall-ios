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
    
    var indicator: ActivityIndicator?
    
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
        self.indicator = ActivityIndicator(view: self.view,
                                           darkView: darkView)
    
        self.indicator?.startLoading()
        self.tableView?.dataSource = self
        self.fetchCallLogsFromServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateCallHistories()
    }
    
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
        didTapCallHistoryCell(cell)
    }
    
    func fetchCallLogsFromServer() {
        self.query?.next { callLogs, error in
            guard let newCallLogs = callLogs, !newCallLogs.isEmpty else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.indicator?.stopLoading()
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Update callLogs
                let newHistories = newCallLogs.map { $0.convertToCallHistory() }
                let previousSet = NSMutableOrderedSet(array: self.callHistories)
                let newSet = NSMutableOrderedSet(array: newHistories)
                previousSet.union(newSet)
                guard let updatedSet = previousSet.array as? [CallHistory] else { return }
                
                // Store to UserDefaults
                UserDefaults.standard.callHistories = updatedSet
                
                self.updateCallHistories()
            }
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
    func didTapVoiceCallButton(_ cell: CallHistoryTableViewCell, dialParams: DialParams) {
        cell.voiceCallButton.isEnabled = false
        self.indicator?.startLoading()
        
        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                cell.voiceCallButton.isEnabled = true
                guard let self = self else { return }
                self.indicator?.stopLoading()
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
    
    func didTapVideoCallButton(_ cell: CallHistoryTableViewCell, dialParams: DialParams) {
        cell.videoCallButton.isEnabled = false
        self.indicator?.startLoading()
        
        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                cell.videoCallButton.isEnabled = true
                guard let self = self else { return }
                self.indicator?.stopLoading()
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
    
    func didTapCallHistoryCell(_ cell: CallHistoryTableViewCell) {
        guard let remoteUserID = cell.remoteUserIDLabel.text else { return }
        let isVideoCall = cell.callHistory.callTypeImageURL.lowercased().contains("video") == true
        let dialParams = DialParams(calleeId: remoteUserID,
                                    isVideoCall: isVideoCall,
                                    callOptions: CallOptions(isAudioEnabled: true,
                                                             isVideoEnabled: isVideoCall,
                                                             localVideoView: nil,
                                                             remoteVideoView: nil,
                                                             useFrontCamera: true),
                                    customItems: [:])
        
        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                cell.videoCallButton.isEnabled = true
                guard let self = self else { return }
                self.indicator?.stopLoading()
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
}

extension UIApplication {
    func showError(with message: String) {
        if let topViewController = UIViewController.topViewController {
            topViewController.presentErrorAlert(message: message)
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.presentErrorAlert(message: message)
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
    }
    
    func showCallController(with call: DirectCall) {
        // If there is termination: Failed to load VoiceCallViewController from Main.storyboard. Please check its storyboard ID")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: call.isVideoCall ? "VideoCallViewController" : "VoiceCallViewController")
        
        if var dataSource = viewController as? DirectCallDataSource {
            dataSource.call = call
            dataSource.isDialing = false
        }
        
        if let topViewController = UIViewController.topViewController {
            topViewController.present(viewController, animated: true, completion: nil)
        } else {
            self.keyWindow?.rootViewController = viewController
            self.keyWindow?.makeKeyAndVisible()
        }
    }
}
