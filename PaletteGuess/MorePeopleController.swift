//
//  MorePeopleController.swift
//  PaletteGuess
//
//  Created by mugua on 2019/7/26.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import ChameleonFramework

class PeopleCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class MorePeopleController: UICollectionViewController {
    
    let bgColor = UIColor(averageColorFrom: UIImage(named: "start_bg_image")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.hidesNavigationBarHairline = true
        self.title = "等待玩家加入"
        
        self.collectionView!.register(PeopleCell.self, forCellWithReuseIdentifier: "PeopleCell")
        self.collectionView.backgroundColor = bgColor
    }
}
