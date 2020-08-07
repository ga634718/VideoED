//
//  CollectionViewCell.swift
//  demo
//
//  Created by Z on 6/29/20.
//  Copyright © 2020 Z. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initCollectionCell(title: String, img: String){
        txtTitle.text = title
        imgIcon.image = UIImage(named: img)
    }
}
