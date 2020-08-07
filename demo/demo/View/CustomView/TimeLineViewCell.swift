//
//  TimeLineView.swift
//  demo
//
//  Created by Z on 7/4/20.
//  Copyright © 2020 Z. All rights reserved.
//

import UIKit

class TimeLineViewCell: UICollectionViewCell {

    @IBOutlet weak var imag: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initTimelineCell(img: UIImage) {
        imag.image = img
    }
    
}
