//
//  Peer+role.swift
//  PaletteGuess
//
//  Created by mugua on 2019/7/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import MultiPeer


fileprivate var isPainterAssociationKey: UInt8 = 0

extension Peer {
    
    var isPainter: Bool {
        get {
            var associateValue = objc_getAssociatedObject(self, &isPainterAssociationKey)
            if associateValue == nil {
                associateValue = false
            }
            return associateValue as! Bool
        }
        
        set {
            objc_setAssociatedObject(self, &isPainterAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}


extension Peer: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.peerID)
        hasher.combine(self.state)
        hasher.combine(self.isPainter)
    }
    
    public var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
    
    public static func == (lhs: Peer, rhs: Peer) -> Bool {
        return lhs.peerID == rhs.peerID
    }
}
