//
//  Register_VC.swift
//  UbonSocial
//
//  Created by cyberwar on 12/4/2557 BE.
//  Copyright (c) 2557 Nextor. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class Register_VC: UIViewController {

    
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtRepassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

    @IBAction func gotoLogin(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func sendSignup(sender: AnyObject) {
        
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        var username:String = txtUsername.text as String
        var password:String = txtPassword.text as String
        var repassword:String = txtPassword.text as String
        
        if ( username == "" || password == "" || repassword == "" ) {
            
            var alertView:UIAlertView = UIAlertView()
                alertView.title = "ล้มเหลว"
                alertView.message = "กรุณาหรอกข้อมูลให้ครบถ้วน!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            HUDController.sharedController.hide(animated: true)
            return
        
        }
        if ( password != repassword ) {
            var alertView:UIAlertView = UIAlertView()
                alertView.title = "ล้มเหลว"
                alertView.message = "กรุณายืนยันรหัสผ่านให้ถูกต้อง!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            HUDController.sharedController.hide(animated: true)
            return
            
        }
        
        let parameters = [
            "action": "doSignUp",
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
                    if response["result"] == "ERROR_USER_LENGTH" {
                        var alertView:UIAlertView = UIAlertView()
                            alertView.title = "ล้มเหลว"
                            alertView.message = "ชื่อผู้ใช้ที่แนะนำคือ 6-20 ตัวอักษร!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                    }
                    if response["result"] == "ERROR_QUERY" {
                        var alertView:UIAlertView = UIAlertView()
                            alertView.title = "ล้มเหลว"
                            alertView.message = "เชื่อมต่อล้มเหลว!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                    }
                    if response["result"] == "ERROR_USER_DUPLICATED" {
                        var alertView:UIAlertView = UIAlertView()
                            alertView.title = "ล้มเหลว"
                            alertView.message = "ชื่อผู้ใช้นี้ถูกใช้งานแล้ว!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                    }
                    if response["result"] == "ERROR_PASS_LENGTH" {
                        var alertView:UIAlertView = UIAlertView()
                            alertView.title = "ล้มเหลว"
                            alertView.message = "รหัสผ่านที่แนะนำคือ 6-20 ตัวอักษร!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                    }
                    if response["result"] == "SUCCESS" {
                        var alertView:UIAlertView = UIAlertView()
                            alertView.title = "สำเร็จ"
                            alertView.message = "ลงทะเบียนสำเร็จแล้ว!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()

                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
        }
        
    }

}
