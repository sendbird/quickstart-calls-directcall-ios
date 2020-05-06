//
//  CallHistoryViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/29.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class CallHistoryViewController: UITableViewController {
    var query: DirectCallLogListQuery?
    var callLogs: [DirectCallLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // query
        let params = DirectCallLogListQuery.Params()
        params.limit = 2
        self.query = SendBirdCall.createDirectCallLogListQuery(with: params)
        
        self.callLogs = UserDefaults.standard.callLogs
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.callLogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "directCallLogCell", for: indexPath) as! CallHistoryTableViewCell
        cell.delegate = self
        cell.directCallLog = self.callLogs[indexPath.row]
        return cell
    }
    
    @IBAction func didTapCreateQuery() {
        self.query?.next { callLogs, error in
            guard let newCallLogs = callLogs else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.presentErrorAlert(message: error?.localizedDescription ?? "There is no more call logs")
                }
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Update callLogs
                let previousLogs = NSMutableOrderedSet(array: self.callLogs)
                let newLogs = NSMutableOrderedSet(array: newCallLogs)
                previousLogs.union(newLogs)
                guard let updatedLogs = previousLogs.array as? [DirectCallLog] else { return }
                self.callLogs = updatedLogs
                
                self.updateCallHistories()
            }
        }
    }
    
    func updateCallHistories() {
        self.tableView.reloadData()
        UserDefaults.standard.callLogs = self.callLogs
    }
}

extension CallHistoryViewController: DirectCallLogDelegate {
    func directCallLog(didUpdateTo updatedLog: DirectCallLog) {
        print("[DirectCallLogDelegate]\n\(updatedLog.duration)\n\(updatedLog.startedAt)\n\(updatedLog.endedAt)\n\(updatedLog.endedBy?.userId ?? "Unknown")")
        self.callLogs.insert(updatedLog, at: 0)
        self.tableView.reloadData()
    }
}

extension CallHistoryViewController: CallHistoryCellDelegate {
    func didStartVoiceCall(_ cell: CallHistoryTableViewCell, dialParams: DialParams) {
        
        SendBirdCall.dial(with: dialParams) { call, error in
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
    
    func didStartVideoCall(_ cell: CallHistoryTableViewCell, dialParams: DialParams) {
        SendBirdCall.dial(with: dialParams) { call, error in
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
