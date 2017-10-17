import UIKit
import MultipeerConnectivity
import SwiftyButton
import RxSwift
import RxCocoa

enum ConnectionState {
    case connecting
    case connected
    case notConnected
    case error
}

class PeerIDStateTuple : Equatable {
    let peerID: MCPeerID
    var state: ConnectionState
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
        self.state = .notConnected
    }
    
    static func ==(lhs: PeerIDStateTuple, rhs: PeerIDStateTuple) -> Bool {
        return lhs.peerID == rhs.peerID
    }
}

