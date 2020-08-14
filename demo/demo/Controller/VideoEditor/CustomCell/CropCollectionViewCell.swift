//
//  CropCollectionViewCell.swift
//  demo
//
//  Created by Hoang Ga on 8/14/20.
//  Copyright © 2020 Z. All rights reserved.
//

import UIKit

class CropCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var txtRatio: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func initView(ratio: String) {
        txtRatio.text = ratio
    }

}
