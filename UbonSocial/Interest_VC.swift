//
//  Interest_VC.swift
//  UbonSocial
//
//  Created by JeansiMac27 on 2/6/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class Interest_VC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var interestTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleNavigationBar()
        var color = UIColor.redColor()
        self.navigationController?.navigationBar.tintColor = color
        
        self.interestTableView?.delegate = self;
        self.interestTableView?.dataSource = self;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var UID = prefs.stringForKey("UID")!
        
        let parameters = [
            "action": "doRequestLikeTopic",
            "UID": UID
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
                        
                        likeList = JSON(json!)
                        
                        self.interestTableView.reloadData()
                    }
                    
                }
                
                HUDController.sharedController.hide(animated: true)
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likeList["likeList"].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var interestcell:InterestCell = self.interestTableView.dequeueReusableCellWithIdentifier("InterestCell") as InterestCell
        
        var imageUrl: String? = likeList["likeList"][indexPath.row]["topic_Picture"].stringValue
        if imageUrl == "0" {
            imageUrl = appConfig["imageUploads"]! + "nopicture.jpg"
        } else {
            imageUrl = appConfig["imageUploads"]! + likeList["likeList"][indexPath.row]["topic_Picture"].stringValue
        }
        let contentImageURL = NSURL(string: imageUrl!)
        let contentImage = NSData(contentsOfURL: contentImageURL!)
        let imageContent = UIImage(data: contentImage!)
        
        interestcell.InterestImageView.image = imageContent
        interestcell.InterestTitle.text = likeList["likeList"][indexPath.row]["topic_Name"].stringValue
        interestcell.InterestContent.text = likeList["likeList"][indexPath.row]["topic_Content"].stringValue
        
        return interestcell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if (segue.identifier == "showDetail") {
            
            var indexPath:NSIndexPath = self.interestTableView.indexPathForSelectedRow()!
            let destinationVC = segue.destinationViewController as Detail_VC
            
            destinationVC.topicID = likeList["likeList"][indexPath.row]["topic_ID"].stringValue
            destinationVC.txtTimeDetail = likeList["likeList"][indexPath.row]["topic_LastCreate"].stringValue
            destinationVC.txtUsernameDetail = likeList["likeList"][indexPath.row]["member_Username"].stringValue
            destinationVC.txtCategoryDetail = likeList["likeList"][indexPath.row]["category_Name"].stringValue
            destinationVC.txtTitleDetail = likeList["likeList"][indexPath.row]["topic_Name"].stringValue
            destinationVC.txtContentDetail = likeList["likeList"][indexPath.row]["topic_Content"].stringValue
            destinationVC.txtView = likeList["likeList"][indexPath.row]["topic_Views"].stringValue
            destinationVC.txtLike = likeList["likeList"][indexPath.row]["totalLike"].stringValue
            
            var imageUrl: String? = likeList["likeList"][indexPath.row]["topic_Picture"].stringValue
            if imageUrl == "0" {
                imageUrl = appConfig["imageUploads"]! + "nopicture.jpg"
            } else {
                imageUrl = appConfig["imageUploads"]! + likeList["likeList"][indexPath.row]["topic_Picture"].stringValue
            }
            destinationVC.imageContentDetail = imageUrl!
            
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

