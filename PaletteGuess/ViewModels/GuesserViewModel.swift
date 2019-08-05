//
//  GuesserViewModel.swift
//  PaletteGuess
//
//  Created by mugua on 2019/8/3.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MultiPeer

class GuesserViewModel {
    
    private var targetWord: String?
    let obGuessWord = BehaviorRelay<String?>(value: nil)
    private let disposeBag = DisposeBag()
    
    init() {
        
        PeerMiddleware.shared.obReceiveText.subscribe(onNext: {[weak self] (str) in
            self?.targetWord = str
            
        }).disposed(by: disposeBag)
        
    }
    
    func broadcastIamWinner() {
        let myself = MultiPeer.instance.currentPeer.toHandyJSONPeer()
        myself.isWinner = true
        let jsonString = myself.toJSONString()
        
        if let data = jsonString?.data(using: .utf8) {
            MultiPeer.instance.send(data: data, type: PeerSendDataType.peer.rawValue)
        }
    }
    
    func checkWordsCorrectness() -> Bool {
        if obGuessWord.value == targetWord {
            return true
        } else {
            return false
        }
    }
    
    func changeDescribeText() -> Observable<String?> {
        
        var switchNoti = false
        
        return Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance).map {[weak self] (second) -> String? in
            
            switchNoti = !switchNoti
            
            if switchNoti {
                return "重要 游戏提示 !"
            } else {
                guard let noOption = self?.targetWord else {
                    return "暂无提示"
                }
                
                switch second {
                case 0, 1, 2:
                    let wordCount = noOption.count.description
                    return "要猜测的词语一共 【\(wordCount)个字】"
                case 3, 4, 5:
                    
                    if self?.targetWord?.contains(self?.obGuessWord.value ?? "") ?? false {
                        return "已经猜对\(arc4random_uniform(80))%, 加油!"
                    } else {
                        let wordCount = noOption.count.description
                        return "要猜测的词语一共 【\(wordCount)个字】"
                    }
                default:
                     return "暂无提示"
                }
    
            }
        }
    }
}
