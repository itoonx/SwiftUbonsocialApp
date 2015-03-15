//
//  Comment_VC.swift
//  UbonSocial
//
//  Created by JeansiMac27 on 1/28/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class Comment_VC: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var CommentTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    var topicID:String?
    
    override func viewDidLoad() {
        
        self.CommentTableView?.delegate = self;
        self.CommentTableView?.dataSource = self;
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.requestCommentList()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        commentTextField.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList["commentList"].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:CommentCell = self.CommentTableView?.dequeueReusableCellWithIdentifier("CommentCell") as CommentCell
        
        // Display Photo
        var photoUrl: String? = commentList["commentList"][indexPath.row]["member_Display"].stringValue
        if photoUrl == "0" {
            photoUrl = appConfig["profileUploads"]! + "guest.jpg"
        } else {
            photoUrl = appConfig["profileUploads"]! + commentList["commentList"][indexPath.row]["member_Display"].stringValue
        }
        let ownerTopicPhotoURL = NSURL(string: photoUrl!)
        let ownerTopicPhoto = NSData(contentsOfURL: ownerTopicPhotoURL!)
        let imageProfile = UIImage(data: ownerTopicPhoto!)
        cell.commentOwnerPicture.image = imageProfile
        
        
        cell.commentNameLabel.text = commentList["commentList"][indexPath.row]["member_Username"].stringValue
        cell.commentDescriptionLabel.text = commentList["commentList"][indexPath.row]["comment_Content"].stringValue
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.dateFromString(commentList["commentList"][indexPath.row]["comment_CreateTime"].stringValue)
        var timeago = NSDate(timeInterval: 0, sinceDate: date!)
        cell.commentTimeLabel.text = timeago.timeAgo
        
        return cell
    }

    @IBAction func doSendComment(sender: AnyObject) {
        
        if (commentTextField.text == "" || topicID == nil) {
            return
        }
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var UID = prefs.stringForKey("UID")!
        
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        let parameters = [
            "action": "doComment",
            "topicID": toString(topicID!),
            "ownerID": UID,
            "comment": commentTextField.text
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
                        
                        self.commentTextField.text = ""
                        self.commentTextField.resignFirstResponder()
                        
                        self.requestCommentList()
                    }
                    
                }
        }
    }
    
    func requestCommentList() {
        
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        let parameters = [
            "action": "doRequestComment",
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
                        
                        commentList = JSON(json!)
                        
                        self.CommentTableView.reloadData()
                    }
                    
                }
                
                HUDController.sharedController.hide(animated: true)
        }
    }
}
