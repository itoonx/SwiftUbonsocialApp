//
//  ChangPassword_VC.swift
//  UbonSocial
//
//  Created by JeansiMac27 on 1/14/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class ChangPassword_VC: UIViewController {

    @IBOutlet weak var yourPasswordLabel: UITextField!
    @IBOutlet weak var newPasswordLabel: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UITextField!
    
    
    override func viewDidLoad() {
        
        self.styleNavigationBar()
        var color = UIColor.redColor()
        self.navigationController?.navigationBar.tintColor = color
    }
    
    @IBAction func doCancelChangePassword(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func doConfirmChangePassword(sender: AnyObject) {
        
        if newPasswordLabel.text != confirmPasswordLabel.text {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "ล้มเหลว"
            alertView.message = "ยืนยันรหัสผ่านไม่ถูกต้อง"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            return
        }
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var UID = prefs.stringForKey("UID")!
        
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        // ตรวจสอบสถานะความสนใจ
        let parameters2 = [
            "action": "doRequestChangePassword",
            "UID": UID,
            "oldPassword": yourPasswordLabel.text,
            "newPassword": confirmPasswordLabel.text
        ]
        
        Alamofire.request(.POST, appConfig["apiURL"]!, parameters: parameters2)
            .responseString { (req, res, str, error)  in
                if appConfig["httpDebugMode"]! == "true" {
                    println("ERROR : \(error)")
                    println("REQUEST : \(req)")
                    println("RESPONSE : \(res)")
                    println("MESSAGE : \(str)")
                }
                
            }
            .responseJSON { (req, res, json, error)  in
                
                println(json)
                
                if error != nil {
                    // HTTP ERROR
                } else {
                    var response = JSON(json!)
                    
                    HUDController.sharedController.hide(animated: true)
                    
                    if response["result"] == "NO_ACTION" {
                        println("NO_ACTION")
                    }
                    if response["result"] == "ERROR_EMPTY" {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "ล้มเหลว"
                        alertView.message = "ข้อมูลไม่ครบถ้วน!"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    if response["result"] == "ERROR_QUERY" {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "ล้มเหลว"
                        alertView.message = "การประมวลผลล้มเหลว"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    if response["result"] == "ERROR_OLD_PASSWORD" {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "ล้มเหลว"
                        alertView.message = "รหัสผ่านเดิมไม่ถูกต้อง!"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    if response["result"] == "SUCCESS" {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "สำเร็จ"
                        alertView.message = "เปลี่ยนรหัสผ่านเรียบร้อย"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
        }

        
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
