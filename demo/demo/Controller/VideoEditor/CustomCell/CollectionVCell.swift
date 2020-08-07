//
//  CollectionVCell.swift
//  MT
//
//  Created by Hoang Ga on 7/24/20.
//  Copyright © 2020 Hoang Ga. All rights reserved.
//

import UIKit

class CollectionVCell: UICollectionViewCell {

    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func initView(title: String, img: String) {
        txtTitle.text = title
        icon.image = UIImage(named: img)
    }

}
