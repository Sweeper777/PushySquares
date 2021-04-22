import MultipeerConnectivity

enum ConnectionState {
    case connecting
    case connected
    case notConnected
    case error
}

struct PeerIDStateTuple : Equatable {
    let peerID: MCPeerID
    var state: ConnectionState

    init(peerID: MCPeerID) {
        self.peerID = peerID
        state = .notConnected
    }

    static func ==(lhs: PeerIDStateTuple, rhs: PeerIDStateTuple) -> Bool {
        lhs.peerID == rhs.peerID
    }
}