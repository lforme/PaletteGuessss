//
//  UIView+Ex.swift
//  Dingo
//
//  Created by mugua on 2019/5/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setCircular(value: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = value
    }
    
    
//    [.layerMaxXMinYCorner, .layerMinXMinYCorner] 左右下
//    [.layerMaxXMinYCorner, .layerMinXMinYCorner] 左右上
    // https://stackoverflow.com/questions/4847163/round-two-corners-in-uiview
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }
    
    
    func setShadow(color: UIColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).withAlphaComponent(0.4)) {
        layer.cornerRadius = 10
        layer.shadowColor = color.cgColor
        layer.borderWidth = 0
        layer.borderColor = color.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 2, height: 2)
    }
}
