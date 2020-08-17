//
//  UIColor+Extensions.swift
//  ImageFilter
//
//  Created by 写BUG on 2020/8/17.
//  Copyright © 2020 改BUG. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = (CGFloat)((rgb & 0x00FF00) >> 8) / 255.0
        let b = (CGFloat)(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
