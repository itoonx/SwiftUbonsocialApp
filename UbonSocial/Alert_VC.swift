//
//  Alert_VC.swift
//  UbonSocial
//
//  Created by JeansiMac27 on 2/6/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class Alert_VC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var alertTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.styleNavigationBar()
        var color = UIColor.redColor()
        self.navigationController?.navigationBar.tintColor = color
        
        self.alertTableView?.delegate = self;
        self.alertTableView?.dataSource = self;

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        let parameters = [
            "action": "doRequestAlertMessage"
        ]
        
        Alamofire.request(.POST, appConfig["apiURL"]!, parameters: parameters)
            .responseString { (req, res, str, error)  in

                if appConfig["httpDebugMode"]! == "true" {
                    println("ERROR : \(error)")
                    println("REQUEST : \(req)")
                    println("RESPONSE : \(res)")
                    println("MESSAGE : \(str)")
                }
                
            }
            .responseJSON { (req, res, json, error)  in
                
                if error != nil {
                    // HTTP ERROR
                } else {
                    var response = JSON(json!)
                    
                    if response["result"] == "NO_ACTION" {
                        println("NO_ACTION")
                    }
                    if response["result"] == "ERROR_EMPTY" {
                        // SHOW ERROR
                    }
                    if response["result"] == "ERROR_QUERY" {
                        // SHOW ERROR
                    }
                    if response["result"] == "SUCCESS" {
                        
                        alertMessageList = JSON(json!)
                        
                        self.alertTableView.reloadData()
                    }
                    
                }
                
                HUDController.sharedController.hide(animated: true)
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertMessageList["alertMessageList"].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var alertcell:AlertCell = self.alertTableView.dequeueReusableCellWithIdentifier("AlertCell") as AlertCell
        
        alertcell.alertContentTextView.text = alertMessageList["alertMessageList"][indexPath.row]["alertmessages_Content"].stringValue
        alertcell.alertTimeLabel.text = alertMessageList["alertMessageList"][indexPath.row]["alertmessages_Time"].stringValue
        
        return alertcell
    }
    
    func styleNavigationBar() {
        
        var color:UIColor = UIColor.blackColor()
        self.navigationController?.navigationBar.barTintColor = color
        
        var attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18)!
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
    }

}
