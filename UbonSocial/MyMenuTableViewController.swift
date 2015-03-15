//
//  MyMenuTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit
import Alamofire

class MyMenuTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedMenuItem : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
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
                
                if error != nil {
                    // HTTP ERROR
                } else {
                    var response = JSON(json!)
                    
                    if response["result"] == "NO_ACTION" {
                        println("NO_ACTION")
                    }
                    if response["result"] == "ERROR_QUERY" {
                        // ERROR
                    }
                    if response["result"] == "SUCCESS" {
                        
                        categoryList = JSON(json!)
                        
                        if categoryList["categories"].count > 0 {
                            self.tableView.reloadData()
                        }
                        
                    }
                    
                }
        }
        
        if categoryList.count > 0 {
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.

        return categoryList["categories"].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell") as? UITableViewCell
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CategoryCell")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        cell!.textLabel?.text = categoryList["categories"][indexPath.row]["category_Name"].stringValue
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == selectedMenuItem {
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)

            selectedMenuItem = -1
            categorySelected = 0
            
            NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
            
            return
        }
        
        selectedMenuItem = indexPath.row
        
        categorySelected = categoryList["categories"][indexPath.row]["category_ID"].stringValue.toInt()!
        
        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
    }
    
}
