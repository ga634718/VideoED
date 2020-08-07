//
//  BackgroundColorViewCell.swift
//  MT
//
//  Created by Hoang Ga on 7/1/20.
//  Copyright © 2020 Hoang Ga. All rights reserved.
//

import UIKit

class BackgroundColorViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var imgColor: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func initView(uiColor: UIColor) {
        
        if #available(iOS 11.0, *) {
            imgColor.backgroundColor = uiColor
        } else {
            print("aa")
        }
    }
}
//struct ModelBackgroundColor {
//    let name: String
//    let uiColor: UIColor
//}
