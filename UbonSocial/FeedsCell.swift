//
//  FeedsCell.swift
//  UbonSocial
//
//  Created by cyberwar on 12/6/2557 BE.
//  Copyright (c) 2557 Nextor. All rights reserved.
//

import UIKit




class FeedsCell: UITableViewCell {

    // normal-mode
    @IBOutlet var imageProfile: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelTitleName: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet weak var imageThumbnail: UIImageView!
    
    @IBOutlet weak var labelTime: UILabel!
    
    @IBOutlet weak var bgContent: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         var mainColor:UIColor = UIColor(red: 216.0/255, green: 58.0/255 , blue: 58.0/255, alpha: 1.0)
         var mainColorLight:UIColor = mainColor.colorWithAlphaComponent(0.1)
        
         var neutralColor:UIColor = UIColor(white: 0.2, alpha: 1.0)
         var fontName:String = "EuphemiaUCAS"
         var boldFontName:String = "EuphemiaUCAS-Bold"

        
        self.labelTitleName.textColor = mainColor
        self.labelTitleName.font = UIFont(name: boldFontName, size: 13.0)
        
        self.labelName.textColor = neutralColor
        self.labelName.font = UIFont(name: fontName, size: 12.0)
        
        self.labelContent.font =  UIFont(name: fontName, size: 12.0)
        self.labelContent.numberOfLines = 2
        
        self.imageProfile.clipsToBounds = true
        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2;
  
    }

}
