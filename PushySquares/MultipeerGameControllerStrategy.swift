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

    var myColor: Color {
        turns[session.myPeerID]!
    }

    func didRestartGame() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(kCircleIconHeight: 56, showCloseButton: false))
        alert.addButton("OK".localized, action: {})
        _ = alert.showCustom(
                String(format: "Your color is %@.".localized, BoardView.colorToString[myColor]!),
                subTitle: "", color: .black,
                icon: BoardView.colorToUIColor[myColor]!.image(size: CGSize(width: 56, height: 56)))
        gameViewController.setAllGestureRecognisersEnabled(
                myColor == gameViewController.game.currentPlayer.color
        )
    }

}

extension MultipeerGameControllerStrategy: MCSessionDelegate {


}