//
//  MultiPeer+Ex.swift
//  PaletteGuess
//
//  Created by mugua on 2019/8/1.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import MultiPeer
import MultipeerConnectivity

fileprivate var currentPeerAssociationKey: UInt8 = 0

extension MultiPeer {

    var currentPeer: Peer {
        get {
            var associateValue = objc_getAssociatedObject(self, &currentPeerAssociationKey)
            if associateValue == nil {
                associateValue = Peer(peerID: MultiPeer.instance.devicePeerID, state: .connected)
            }
            return associateValue as! Peer
        }
        
        set {
            objc_setAssociatedObject(self, &currentPeerAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
