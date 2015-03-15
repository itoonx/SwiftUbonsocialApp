//
//  Login_VC.swift
//  UbonSocial
//
//  Created by cyberwar on 12/4/2557 BE.
//  Copyright (c) 2557 Nextor. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class Login_VC: UIViewController, UITextFieldDelegate {

    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.txtUsername.delegate = self;
        self.txtPassword.delegate = self;
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.view.endEditing(true);
        return false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup Gesture for Keyboard
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendLogin(sender: AnyObject) {
        
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        var username:String = txtUsername.text as String
        var password:String = txtPassword.text as String
        
        let parameters = [
            "action": "doSignIn",
            "username": username,
            "password": password
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
                    
                    HUDController.sharedController.hide(animated: true)
                    
                    if response["result"] == "NO_ACTION" {
                        println("NO_ACTION")
                    }
                    if response["result"] == "ERROR_EMPTY" {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "ล้มเหลว"
                        alertView.message = "กรุณากรอกข้อมูลให้ครบถ้วน!"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    if response["result"] == "ERROR_USER_FORMAT" {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "ล้มเหลว"
                        alertView.message = "รูปแบบข้อมูลไม่ถูกต้อง!"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }

                    if response["result"] == "ERROR_QUERY" {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "ล้มเหลว"
                        alertView.message = "เชื่อมต่อผิดพลาด!"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    if response["result"] == "WRONG" {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "ล้มเหลว"
                        alertView.message = "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง!"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    if response["result"] == "SUCCESS" {
                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        prefs.setObject(response["name"].stringValue, forKey: "USERNAME")
                        prefs.setObject(response["displayImage"].stringValue, forKey: "DISPLAYIMAGE")
                        prefs.setObject(response["UID"].stringValue, forKey: "UID")
                        prefs.synchronize()
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                }
        }
        
    }
    
}
