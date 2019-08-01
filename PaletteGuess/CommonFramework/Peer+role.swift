//
//  Peer+role.swift
//  PaletteGuess
//
//  Created by mugua on 2019/7/27.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import MultiPeer
import HandyJSON
import MultipeerConnectivity

fileprivate var isPainterAssociationKey: UInt8 = 0

extension Peer {
    
    func toHandyJSONPeer() -> HandyJSONPeer {
        let p = HandyJSONPeer()
        p.displayName = peerID.displayName
        p.isPainter = isPainter
        if let s = HandyJSONPeer.ConnectionState(rawValue: state.rawValue) {
            p.connectionState = s
        }
        return p
    }
    
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

public class HandyJSONPeer: HandyJSON {
    
    public enum ConnectionState: Int, HandyJSONEnum {
        case notConnected = 0
        case connecting
        case connected
    }
    
    public var displayName: String!
    public var connectionState: ConnectionState!
    public var isPainter: Bool!
    
    required public init() { }
    
    func toPeer() -> Peer {
        let p = Peer(peerID: MCPeerID(displayName: displayName), state: MCSessionState(rawValue: connectionState.rawValue)!)
        p.isPainter = isPainter
        return p
    }
}
