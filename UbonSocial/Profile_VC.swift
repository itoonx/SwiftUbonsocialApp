//
//  Profile_VC.swift
//  UbonSocial
//
//  Created by cyberwar on 1/13/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit

class Profile_VC: UIViewController {

    @IBOutlet weak var uiwebView: UIWebView!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var UIname: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleNavigationBar()
        var color = UIColor.redColor()
        self.navigationController?.navigationBar.tintColor = color
        
        // set background
        var filepath = NSBundle.mainBundle().pathForResource("screenbgview", ofType: "png")
        var gifImage: AnyObject? = NSData.dataWithContentsOfMappedFile(filepath!)
        uiwebView.loadData(gifImage as NSData, MIMEType: "image/png", textEncodingName: nil, baseURL: nil)
        uiwebView.userInteractionEnabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var profileName:String = prefs.stringForKey("USERNAME")!
        var imageURL:String = prefs.stringForKey("DISPLAYIMAGE")!
        
        if imageURL == "0" {
            imageURL = appConfig["profileUploads"]! + "guest.jpg"
        } else {
            imageURL = appConfig["profileUploads"]! + imageURL
        }
        
        UIname.text = profileName
        
        let url = NSURL(string: imageURL)
        let data = NSData(contentsOfURL: url!)
        imageProfile.image = UIImage(data: data!)
        
        self.imageProfile.clipsToBounds = true
        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2;
        self.imageProfile.layer.borderWidth = 3.0;
        self.imageProfile.layer.borderColor = UIColor.whiteColor().CGColor

    }
    
    @IBAction func doLogout(sender: AnyObject) {
        
        var appDomain = NSBundle.mainBundle().bundleIdentifier
        var prefs = NSUserDefaults.standardUserDefaults()
        prefs.removePersistentDomainForName(appDomain!)
        
        self.performSegueWithIdentifier("gotoLogin", sender: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
