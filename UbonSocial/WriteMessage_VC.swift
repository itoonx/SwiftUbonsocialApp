//
//  WriteMessage_VC.swift
//  UbonSocial
//
//  Created by cyberwar on 1/6/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class WriteMessage_VC: UIViewController ,UITextViewDelegate ,UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate{

    @IBOutlet var Scroller: UIScrollView!
    @IBOutlet var textview: UITextView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var myImageChoose: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var categoryLabel: UIBarButtonItem!
    @IBOutlet weak var topicTitle: UITextField!
    
    var toolbar: UIToolbar?
    var cameraButton: UIBarButtonItem?
    var flexSpace: UIBarButtonItem?
    var categoryButton: UIBarButtonItem?
    
    var categorySheet: UIActionSheet = UIActionSheet();
    var categorySelected: Int = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCategory()

        self.Scroller.scrollEnabled = true
        self.Scroller.contentSize = CGSize(width: 320, height: 480)
        
        textview.delegate = self
        
        toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.bounds.size.width, 44))
        
        cameraButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "attachPhoto")
        cameraButton!.tintColor = UIColor.orangeColor()
        
        flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        categoryButton = UIBarButtonItem(title: "ข่าวทั่วไป", style: .Plain, target: self, action: "showCategorySheet")
        categoryButton!.tintColor = UIColor.orangeColor()
        
        toolbar?.setItems([cameraButton!, flexSpace!, categoryButton!], animated: true)
        
        self.textview.inputAccessoryView = toolbar
        self.toolBar = toolbar
    }
    
    func getCategory() {
        
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        let parameters = [
            "action": "doRequestCategory"
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
                
                HUDController.sharedController.hide(animated: true)
                
                if error != nil {
                    // HTTP ERROR
                } else {
                    var response = JSON(json!)
                    
                    if response["result"] == "NO_ACTION" {
                        println("NO_ACTION")
                    }
                    if response["result"] == "ERROR_QUERY" {
                        self.categoryLabel.title = "ERROR_QUERY"
                    }
                    if response["result"] == "SUCCESS" {
                        
                        // Initial category
                        self.categoryLabel.title = response["categories"][0]["category_Name"].stringValue
                        
                        let categoriesList = response["categories"]
                        
                        self.categorySheet.addButtonWithTitle("ยกเลิก");
                        
                        // Create category sheet
                        for index in 0..<categoriesList.count {
                            let title = categoriesList[index]["category_Name"].stringValue
                            self.categorySheet.addButtonWithTitle(title);
                        }
                        
                        self.categorySheet.cancelButtonIndex = 0;
                    }
                    
                }
        }
    }
    
    @IBAction func attachPhoto(sender: AnyObject) {
        attachPhoto()
    }
    
    func attachPhoto() {
        var photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .PhotoLibrary
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        myImageChoose.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        if (textview.text == "") {
            textViewDidEndEditing(textview)
        }
        if (textView.text == "Say something..." ) {
            submitButton.enabled = false
        }else {
            submitButton.enabled = true
        }
        
    }
    
    func textViewDidEndEditing(textview: UITextView) {
        if (textview.text == "") {
            textview.text = "Say something..."
            textview.textColor = UIColor.lightGrayColor()
        }
        
        textview.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(textview: UITextView){
        if (textview.text == "Say something..."){
            textview.text = ""
            textview.textColor = UIColor.blackColor()
        }
        
        textview.becomeFirstResponder()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        textview.resignFirstResponder()
    }
    
    @IBAction func doCancel(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
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
    
    @IBAction func updateCategory(sender: AnyObject) {
        showCategorySheet()
    }
    
    func showCategorySheet() {
        categorySheet.title  = "กรุณาเลือกหมวดหมู่ข่าว";
        categorySheet.delegate = self;
        categorySheet.showInView(self.view);
    }
    
    func actionSheet(sheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
       
        if buttonIndex == 0 {
            return
        }
            
        categorySelected = buttonIndex
        
        self.categoryLabel.title = sheet.buttonTitleAtIndex(buttonIndex)
        
        categoryButton = UIBarButtonItem(title: sheet.buttonTitleAtIndex(buttonIndex), style: .Plain, target: self, action: "showCategorySheet")
        categoryButton!.tintColor = UIColor.orangeColor()
        
        toolbar?.setItems([cameraButton!, flexSpace!, categoryButton!], animated: true)
        
    }
    
    @IBAction func doSubmit(sender: AnyObject) {
        
        var contentView = HUDContentView.ProgressView()
        HUDController.sharedController.contentView = contentView
        HUDController.sharedController.show()
        
        // doPost
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var UID = prefs.stringForKey("UID")!
        
        var contentString = textview.text
        var imageData: NSData?

        var parameters: [String: AnyObject]
        
        if myImageChoose.image != nil {
            imageData = UIImageJPEGRepresentation(myImageChoose.image, 90)
            parameters = [
                "action": "doPost",
                "UID": UID,
                "title": topicTitle.text!,
                "content": contentString,
                "cateId": categorySelected,
                "file": NetData(data: imageData!, mimeType: .ImageJpeg, filename: "upload.jpg")
            ]
        } else {
            parameters = [
                "action": "doPost",
                "UID": UID,
                "title": topicTitle.text!,
                "content": contentString,
                "cateId": categorySelected
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

                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                    }
                }
        
        }

        
    }
}

