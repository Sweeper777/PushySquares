import MultipeerConnectivity

final class StartInfo : NSObject, NSCoding {
    let turns: [MCPeerID: Int]
    let map: String

}
