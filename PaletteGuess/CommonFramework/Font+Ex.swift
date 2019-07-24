//
//  Font+Ex.swift
//  DoAction
//
//  Created by mugua on 2019/7/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

/*
 label.font = UIFontMetrics.default.scaledFont(for: customFont)
 label.adjustsFontForContentSizeCategory = true
 
 For more information on using scaled fonts, see Scaling Fonts Automatically.
 */

extension UIFont {
    
    static func catFont(size: CGFloat = UIFont.labelFontSize) -> UIFont {
        
        guard let customFont = UIFont(name: "FZYOUMZJW--GB1-0", size: size) else {
            fatalError("没有找到字体")
        }
        
        return customFont
    }
    
    
    static func findAllFontName() {
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
}
