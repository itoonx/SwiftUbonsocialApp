//
//  Newsfeed_VC.swift
//  UbonSocial
//
//  Created by cyberwar on 12/4/2557 BE.
//  Copyright (c) 2557 Nextor. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class Newsfeed_VC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var mTableView: UITableView!
    @IBOutlet weak var mysegmentedControl: UISegmentedControl!
    
    @IBAction func categoryTapped(sender: AnyObject) {
        toggleSideMenuView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.styleNavigationBar()
        var color = UIColor.redColor()
        self.navigationController?.navigationBar.tintColor = color
        
        self.mTableView?.delegate = self;
        self.mTableView?.dataSource = self;
        
        var backgroundView = UIView(frame: CGRectZero)
        self.mTableView.tableFooterView = backgroundView
        self.mTableView.backgroundColor = UIColor.clearColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:", name:"load", object: nil)
        
        loadfeed(self.mTableView)

    }
    
    func loadList(notification: NSNotification){
        //load data here
        self.mTableView.reloadData()
    }
    
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if prefs.stringForKey("UID") == nil {
            self.performSegueWithIdentifier("gotoLogin", sender: self)
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feedList["feedList"].count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:FeedsCell = self.mTableView.dequeueReusableCellWithIdentifier("FeedCell") as FeedsCell
        
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                
                // Display Photo
                var photoUrl: String? = feedList["feedList"][indexPath.row]["member_Display"].stringValue
                if photoUrl == "0" {
                    photoUrl = appConfig["profileUploads"]! + "guest.jpg"
                } else {
                    photoUrl = appConfig["profileUploads"]! + feedList["feedList"][indexPath.row]["member_Display"].stringValue
                }
                
                ImageLoader.sharedLoader.imageForUrl(photoUrl!, completionHandler:{(image: UIImage?, url: String) in
                    cell.imageProfile.image = image
                })

                // Topic Image
                var imageUrl: String? = feedList["feedList"][indexPath.row]["topic_Picture"].stringValue
                if imageUrl == "0" {
                    imageUrl = appConfig["imageUploads"]! + "nopicture.jpg"
                } else {
                    imageUrl = appConfig["imageUploads"]! + feedList["feedList"][indexPath.row]["topic_Picture"].stringValue
                }
                
                ImageLoader.sharedLoader.imageForUrl(imageUrl!, completionHandler:{(image: UIImage?, url: String) in
                    cell.imageThumbnail.image = image
                })
                
                cell.labelName.text = feedList["feedList"][indexPath.row]["member_Username"].stringValue
                cell.labelTitleName.text = feedList["feedList"][indexPath.row]["topic_Name"].stringValue
                cell.labelContent.text = feedList["feedList"][indexPath.row]["topic_Content"].stringValue
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.dateFromString(feedList["feedList"][indexPath.row]["topic_LastCreate"].stringValue)
                var timeago = NSDate(timeInterval: 0, sinceDate: date!)
                cell.labelTime.text = timeago.timeAgo
                
                // Category Check
                if feedList["feedList"][indexPath.row]["category_ID"].stringValue.toInt() != categorySelected && categorySelected != 0 {
                    cell.hidden = true
                }
                
                // Approve Check
                if feedList["feedList"][indexPath.row]["topic_Show"].stringValue.toInt() == 0 {
                    cell.hidden = true
                }
                
                
            }
        }
        
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // Category Check
        if feedList["feedList"][indexPath.row]["category_ID"].stringValue.toInt() != categorySelected && categorySelected != 0 {
            return 0
        }
        
        // Approve Check
        if feedList["feedList"][indexPath.row]["topic_Show"].stringValue.toInt() == 0 {
            return 0
        }
        
        return 213
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (segue.identifier == "showDetail") {
            
            var indexPath:NSIndexPath = self.mTableView.indexPathForSelectedRow()!
            let destinationVC = segue.destinationViewController as Detail_VC
            
            destinationVC.topicID = feedList["feedList"][indexPath.row]["topic_ID"].stringValue
            destinationVC.txtTimeDetail = feedList["feedList"][indexPath.row]["topic_LastCreate"].stringValue
            destinationVC.txtUsernameDetail = feedList["feedList"][indexPath.row]["member_Username"].stringValue
            destinationVC.txtCategoryDetail = feedList["feedList"][indexPath.row]["category_Name"].stringValue
            destinationVC.txtTitleDetail = feedList["feedList"][indexPath.row]["topic_Name"].stringValue
            destinationVC.txtContentDetail = feedList["feedList"][indexPath.row]["topic_Content"].stringValue
            destinationVC.txtView = feedList["feedList"][indexPath.row]["topic_Views"].stringValue
            destinationVC.txtLike = feedList["feedList"][indexPath.row]["totalLike"].stringValue
            
            var imageUrl: String? = feedList["feedList"][indexPath.row]["topic_Picture"].stringValue
            if imageUrl == "0" {
                imageUrl = appConfig["imageUploads"]! + "nopicture.jpg"
            } else {
                imageUrl = appConfig["imageUploads"]! + feedList["feedList"][indexPath.row]["topic_Picture"].stringValue
            }
            destinationVC.imageContentDetail = imageUrl!
            
        }
    }
    
    @IBAction func mySegIndexChanged(sender: AnyObject) {

        if sender.selectedSegmentIndex == 0 {
            
            // ALL
            var contentView = HUDContentView.ProgressView()
            HUDController.sharedController.contentView = contentView
            HUDController.sharedController.show()
            
            let parameters = [
                "action": "doRequestFeed"
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
                        if response["result"] == "ERROR_QUERY" {
                            // SHOW ERROR
                        }
                        if response["result"] == "SUCCESS" {
                            
                            feedList = JSON(json!)
                            
                            self.mTableView.reloadData()

                        }
                        
                    }
                    
                    HUDController.sharedController.hide(animated: true)
            }
            
        } else if sender.selectedSegmentIndex == 1 {
            
            // TODAY
            var contentView = HUDContentView.ProgressView()
            HUDController.sharedController.contentView = contentView
            HUDController.sharedController.show()
            
            let parameters = [
                "action": "doRequestFeedToday"
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
                        if response["result"] == "ERROR_QUERY" {
                            // SHOW ERROR
                        }
                        if response["result"] == "SUCCESS" {
                            
                            feedList = JSON(json!)
                            
                            self.mTableView.reloadData()

                        }
                        
                    }
                    
                    HUDController.sharedController.hide(animated: true)
            }
            
        } else if sender.selectedSegmentIndex == 2 {
            
            // TOP
            var contentView = HUDContentView.ProgressView()
            HUDController.sharedController.contentView = contentView
            HUDController.sharedController.show()
            
            let parameters = [
                "action": "doRequestFeedTop"
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
                        if response["result"] == "ERROR_QUERY" {
                            // SHOW ERROR
                        }
                        if response["result"] == "SUCCESS" {
                            
                            feedList = JSON(json!)
                            
                            self.mTableView.reloadData()
                            
                        }
                        
                    }
                    
                    HUDController.sharedController.hide(animated: true)
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
