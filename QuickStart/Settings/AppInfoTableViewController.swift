//
//  AppInfoTableViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/12.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class AppInfoTableViewController: UITableViewController {
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var appId: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    func setupUI() {
        self.appName.text = Bundle.main.appName ?? "No app name"
        self.appId.text = SendBirdCall.appId ?? "No configured app ID"
    }
}
