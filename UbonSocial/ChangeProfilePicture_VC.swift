//
//  ChangeProfilePicture_VC.swift
//  UbonSocial
//
//  Created by JeansiMac27 on 1/14/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class ChangeProfilePicture_VC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var previewImageProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleNavigationBar()
        var color = UIColor.redColor()
        self.navigationController?.navigationBar.tintColor = color
        
        self.previewImageProfile.clipsToBounds = true
        self.previewImageProfile.layer.cornerRadius = self.previewImageProfile.frame.size.width / 2;
        self.previewImageProfile.layer.borderWidth = 3.0;
        self.previewImageProfile.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    @IBAction func doBrowseImage(sender: AnyObject) {
        var photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .PhotoLibrary
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        previewImageProfile.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        self.dismissViewControllerAnimated(false, completion: nil)

    }
    
    func urlRequestWithComponents(urlString:String, parameters:NSDictionary) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        //let boundaryConstant = "myRandomBoundary12345"
        let boundaryConstant = "NET-POST-boundary-\(arc4random())-\(arc4random())"
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add parameters
        for (key, value) in parameters {
            
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            
            if value is NetData {
                // add image
                var postData = value as NetData
                
                //uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(postData.filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                
                // append content disposition
                var filenameClause = " filename=\"\(postData.filename)\""
                let contentDispositionString = "Content-Disposition: form-data; name=\"\(key)\";\(filenameClause)\r\n"
                let contentDispositionData = contentDispositionString.dataUsingEncoding(NSUTF8StringEncoding)
                uploadData.appendData(contentDispositionData!)
                
                // append content type
                //uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!) // mark this.
                let contentTypeString = "Content-Type: \(postData.mimeType.getString())\r\n\r\n"
                let contentTypeData = contentTypeString.dataUsingEncoding(NSUTF8StringEncoding)
                uploadData.appendData(contentTypeData!)
                uploadData.appendData(postData.data)
                
            }else{
                uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    @IBAction func doConfirmButton(sender: AnyObject) {
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        // doPost
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var UID = prefs.stringForKey("UID")!
        
        var imageData: NSData?

        var parameters: [String: AnyObject]
        
        if previewImageProfile.image != nil {
            imageData = UIImageJPEGRepresentation(previewImageProfile.image, 90)
            parameters = [
                "action": "doUploadProfilePicture",
                "UID": UID,
                "file": NetData(data: imageData!, mimeType: .ImageJpeg, filename: "upload.jpg")
            ]
        } else {
            parameters = [
                "action": "doUploadProfilePicture",
                "UID": UID
            ]
        }
        
        let urlRequest = self.urlRequestWithComponents(appConfig["apiURL"]!, parameters: parameters)
        
        Alamofire.upload(urlRequest.0, urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                //println("uploading... \(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { (req, res, str, error)  in
                
                if appConfig["httpDebugMode"]! == "true" {
                    println("ERROR : \(error)")
                    println("REQUEST : \(req)")
                    println("RESPONSE : \(res)")
                    println("MESSAGE : \(str)")
                }
                
            }
            .responseJSON { (req, res, json, error)  in
                
                HUDController.sharedController.hide(animated: true)
                
                if error != nil {
                    // HTTP ERROR
                } else {
                    var response = JSON(json!)
                    
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
                    if response["result"] == "ERROR_UPLOAD" {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "ล้มเหลว"
                        alertView.message = "อัพโหลดข้อมูลล้มเหลว!"
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
                    if response["result"] == "SUCCESS" {

                        prefs.setObject(response["displayImage"].stringValue, forKey: "DISPLAYIMAGE")
                        
                        self.dismissViewControllerAnimated(true, completion: nil)

                    }
                }
        }
    }
    
    @IBAction func doCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
