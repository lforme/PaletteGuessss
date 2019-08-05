//
//  RealmImageModel.swift
//  PaletteGuess
//
//  Created by mugua on 2019/8/3.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RealmSwift

class RealmImageModel: Object {
    
    @objc dynamic var createdDate = Date()
    @objc dynamic var imageData: Data? = nil
    let joinCount = RealmOptional<Int>()
    
    override static func indexedProperties() -> [String] {
        return ["createdDate"]
    }
    
    func toImage() -> UIImage? {
        guard let d = imageData else {
            return nil
        }
        return UIImage(data: d)
    }
}
