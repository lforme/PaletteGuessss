//
//  PainterViewModel.swift
//  PaletteGuess
//
//  Created by mugua on 2019/8/1.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


struct PainterViewModel {
    var commonWords = ["螃蟹", "口红", "台灯", "空调", "拖鞋", "足球", "油条", "电脑", "香水", "篮球", "雨伞", "饺子", "花瓶", "医生", "蛋糕", "耳机"]
    
    let targetWord = BehaviorRelay<String>(value: "摇一摇更换词组")
}
