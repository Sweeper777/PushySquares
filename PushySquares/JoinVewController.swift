import UIKit
import SwiftyButton
import MultipeerConnectivity

class JoinViewController : UIViewController {
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var connectedPeerID: MCPeerID? {
        didSet {
            if let connectedPeer = connectedPeerID {
                activityIndicator.stopAnimating()
                connectionStatusLabel.text = "Connected to \(connectedPeer.displayName)"
            } else {
                activityIndicator.startAnimating()
                connectionStatusLabel.text = "Waiting to be connected to a game..."
            }
        }
    }
    
    var connectionStatusLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    
}
