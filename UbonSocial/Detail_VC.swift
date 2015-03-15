//
//  Detail_VC.swift
//  UbonSocial
//
//  Created by cyberwar on 1/3/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit
import Alamofire

class Detail_VC: UIViewController {
    
    @IBOutlet var Scroller: UIScrollView!
    
    @IBOutlet weak var likeButton: UIBarButtonItem!
    
    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var ownerPostLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var timePostLabel: UILabel!
    @IBOutlet weak var ThumbnailPhoto: UIImageView!
    @IBOutlet weak var descriptionTextview: UITextView!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!

    var topicID: String?
    var txtTimeDetail : String?
    var txtUsernameDetail : String?
    var txtCategoryDetail : String?
    var txtTitleDetail : String?
    var txtContentDetail : String?
    var imageContentDetail : String?
    var txtView : String?
    var txtLike : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                
                
                self.Scroller.scrollEnabled = true
                self.Scroller.contentSize = CGSizeMake(320, 624);
                
                self.titleLabel.textContainer.maximumNumberOfLines = 2
                
                self.ownerPostLabel.text = self.txtUsernameDetail
                self.titleLabel.text = self.txtTitleDetail
                
                // แปลงเวลาเป็นข้อความ
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.dateFromString(self.txtTimeDetail!)
                var timeago = NSDate(timeInterval: 0, sinceDate: date!)
                self.timePostLabel.text = timeago.timeAgo
                
                self.categoryLabel.text = self.txtCategoryDetail
                
                let contentImageURL = NSURL(string: self.imageContentDetail!)
                let contentImage = NSData(contentsOfURL: contentImageURL!)
                self.ThumbnailPhoto.image = UIImage(data: contentImage!)
                
                self.descriptionTextview.text = self.txtContentDetail
                
                self.viewLabel.text = self.txtView
                self.likeLabel.text = self.txtLike

            }
        }
        
        // นับ View
        let parameters = [
            "action": "doView",
            "topicID": toString(topicID!)
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
                        // Increase View Success
                    }
                    
                }
                
        }
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var UID = prefs.stringForKey("UID")!
        
        // ตรวจสอบสถานะความสนใจ
        let parameters2 = [
            "action": "isLike",
            "UID": UID,
            "TID": toString(topicID!)
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
                        if response["isLike"] == "TRUE" {
                            self.likeButton.enabled = false
                        } else {
                            self.likeButton.enabled = true
                        }
                    }
                }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (segue.identifier == "showComment") {
            
            let destinationVC = segue.destinationViewController as Comment_VC
            
            destinationVC.topicID = topicID
            
        }
    }
    
    @IBAction func doLike(sender: AnyObject) {
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var UID = prefs.stringForKey("UID")!
        
        // ตรวจสอบสถานะความสนใจ
        let parameters2 = [
            "action": "doLike",
            "UID": UID,
            "TID": toString(topicID!)
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
                        self.likeButton.enabled = false
                    }
                    
                }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
