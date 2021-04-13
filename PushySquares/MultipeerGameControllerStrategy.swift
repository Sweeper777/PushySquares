import UIKit
import PushySquaresModel
import MultipeerConnectivity
import SCLAlertView
import SwiftyButton

class MultipeerGameControllerStrategy: NSObject, GameControllerStrategy {
    let session: MCSession
    let turns: [MCPeerID: Color]
    var disconnectHandled = false
    private unowned let gameViewController: GameViewController

    init(session: MCSession, turns: [MCPeerID: Color], gameViewController: GameViewController) {
        self.session = session
        self.turns = turns
        self.gameViewController = gameViewController
        super.init()
        session.delegate = self
    }

}

extension MultipeerGameControllerStrategy: MCSessionDelegate {


}