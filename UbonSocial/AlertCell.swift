//
//  AlertCell.swift
//  UbonSocial
//
//  Created by JeansiMac27 on 2/6/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit

class AlertCell: UITableViewCell {
    
    @IBOutlet weak var alertTimeLabel: UILabel!

    @IBOutlet weak var alertContentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.alertContentTextView.textContainer.maximumNumberOfLines = 3
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
