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

    func didEndAnimatingMoveResult(_ moveResult: MoveResult) {
        gameViewController.setAllGestureRecognisersEnabled(
                myColor == gameViewController.game.currentPlayer.color
        )
    }

    func makeMenuButtons() -> [UIView]? {
        let quitButton = PressableButton()
        let buttonHeight = 40.f
        quitButton.shadowHeight = buttonHeight * 0.1
        quitButton.colors = PressableButton.ColorSet(button: UIColor.gray.desaturated(), shadow: UIColor.gray.desaturated().darker())
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        quitButton.tintColor = .white
        quitButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        quitButton.addTarget(self, action: #selector(quitTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            quitButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            quitButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        return [quitButton]
    }

    @objc func quitTapped() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Yes".localized, action: {
            [weak self] in
            guard let `self` = self else { return }
            self.disconnectHandled = true
            self.gameViewController.dismiss(animated: true)
            self.session.disconnect()
        })
        alert.addButton("No".localized, action: {})
        alert.showWarning("Confirm".localized, subTitle: "Do you really want to quit?".localized)
    }

}

extension MultipeerGameControllerStrategy: MCSessionDelegate {


}