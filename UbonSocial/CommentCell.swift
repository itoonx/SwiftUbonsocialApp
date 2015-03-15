//
//  CommentCell.swift
//  UbonSocial
//
//  Created by JeansiMac27 on 1/28/2558 BE.
//  Copyright (c) 2558 Nextor. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var commentOwnerPicture: UIImageView!
    
    @IBOutlet weak var commentNameLabel: UILabel!
    
    @IBOutlet weak var commentDescriptionLabel: UILabel!
    
    @IBOutlet weak var commentTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.commentOwnerPicture.clipsToBounds = true
        self.commentOwnerPicture.layer.cornerRadius = self.commentOwnerPicture.frame.size.width / 2;
        
    }

}
