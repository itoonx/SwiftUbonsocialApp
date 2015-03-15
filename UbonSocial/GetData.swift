//
//  GetData.swift
//  UbonSocial
//
//  Created by cyberwar on 2/24/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import Foundation
import Alamofire
import PKHUD


    
func loadfeed( tableview:UITableView ) {
    
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
        dispatch_async(dispatch_get_main_queue()) {
            
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
                            tableview.reloadData()

                        }
                        
                    }
                    
                    HUDController.sharedController.hide(animated: true)
            }
            
            
        }
    }
}


