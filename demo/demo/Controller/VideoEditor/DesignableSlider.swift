//
//  DesignableSlider.swift
//  demo
//
//  Created by Hoang Ga on 8/18/20.
//  Copyright © 2020 Z. All rights reserved.
//

import UIKit

@IBDesignable

class DesignableSlider: UISlider {

    @IBInspectable var thumbImage: UIImage? {
        didSet {
            setThumbImage(thumbImage, for: .normal)
        }
    }

    @IBInspectable var thumbHighlightedImage: UIImage? {
          didSet {
              setThumbImage(thumbHighlightedImage, for: .highlighted)
          }
      }

}
