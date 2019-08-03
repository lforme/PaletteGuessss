//
//  PeerMiddleware.swift
//  PaletteGuess
//
//  Created by mugua on 2019/8/3.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import MultiPeer
import RxCocoa
import RxSwift


final class PeerMiddleware: MultiPeerDelegate {
    
    
    static let shared = PeerMiddleware()
    let obChangedDevices = BehaviorRelay<[String]>(value: [])
    let obReceivePeer = BehaviorRelay<Peer?>(value: nil)
    let obReceiveText = BehaviorRelay<String?>(value: nil)
    let obReceivePicture = BehaviorRelay<UIImage?>(value: nil)
    let gameOver = BehaviorRelay<Bool>(value: false)
    
    private init() {
        MultiPeer.instance.delegate = self
    }
    
    func multiPeer(didReceiveData data: Data, ofType type: UInt32) {
        guard let t = PeerSendDataType(rawValue: type) else { return }
        
        switch t {
        case .peer:
            let jsonString = String(data: data, encoding: .utf8)
            let handyJSONPeer = HandyJSONPeer.deserialize(from: jsonString)
            guard let peer = handyJSONPeer?.toPeer() else { break }
            obReceivePeer.accept(peer)
            if peer.isWinner {
                gameOver.accept(true)
            }
            
        case .picture:
            let img = UIImage(data: data)
            obReceivePicture.accept(img)
            
        case .text:
            let text = String(data: data, encoding: .utf8)
            obReceiveText.accept(text)
        }
    }
    
    func multiPeer(connectedDevicesChanged devices: [String]) {
        obChangedDevices.accept(devices)
    }
    
}
