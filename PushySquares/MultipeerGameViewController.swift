import UIKit
import SCLAlertView
import SwiftyButton
import MultipeerConnectivity

class MultipeerGameViewController: GameViewController {
    var session: MCSession!
    var playerColorsDict: [MCPeerID: Color]!
    var disconnectHandled = false
    
}
