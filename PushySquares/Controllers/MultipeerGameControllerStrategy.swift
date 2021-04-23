import UIKit
import PushySquaresModel
import MultipeerConnectivity
import SCLAlertView
import SwiftyButton

class MultipeerGameControllerStrategy: NSObject, GameControllerStrategy {
    let session: MCSession
    let turns: [MCPeerID: Color]
    private var disconnectHandled = false
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

        let threeDButton = PressableButton()
        threeDButton.shadowHeight = buttonHeight * 0.1
        threeDButton.colors = PressableButton.ColorSet(button: UIColor.gray.desaturated(), shadow: UIColor.gray.desaturated().darker())
        threeDButton.translatesAutoresizingMaskIntoConstraints = false
        threeDButton.tintColor = .white
        threeDButton.setImage(UIImage(systemName: "view.3d"), for: .normal)
        threeDButton.addTarget(gameViewController, action: #selector(gameViewController.threeDTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            threeDButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            threeDButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        return [quitButton, threeDButton]
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

    func willMove(_ direction: Direction) {
        switch direction {
        case .right:
            try! session.send(Data([DataCodes.moveRight.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        case .up:
            try! session.send(Data([DataCodes.moveUp.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        case .down:
            try! session.send(Data([DataCodes.moveDown.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        case .left:
            try! session.send(Data([DataCodes.moveLeft.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        }
    }
}

extension MultipeerGameControllerStrategy: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard state == .notConnected else { return }

        if gameViewController.game.players.filter({ $0.lives > 0 }).count < 2 {
            return
        }

        if session.connectedPeers.isEmpty && !disconnectHandled {
            disconnectHandled = true
            if gameViewController.game.players.filter({ $0.lives > 0 }).count > 2 {
                DispatchQueue.main.async { [weak self] in
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    alert.addButton("OK".localized, action: {
                        [weak self] in
                        self?.gameViewController.dismiss(animated: true, completion: nil)
                    })
                    _ = alert.showWarning("Oops!".localized, subTitle: "You disconnected from the game.".localized)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    alert.addButton("OK".localized, action: {
                        [weak self] in
                        self?.gameViewController.dismiss(animated: true, completion: nil)
                    })
                    _ = alert.showWarning("Game Over".localized, subTitle: "All other players disconnected.".localized)
                }
            }
        }

        if !session.connectedPeers.isEmpty {
            DispatchQueue.main.async {
                [weak self] in
                self?.handleDisconnection(of: peerID)
            }

        }
    }

    func handleDisconnection(of peerID: MCPeerID) {
        let moveResult = gameViewController.game.killPlayer(myColor)
        let moveResultWithUnknownGameResult = MoveResult(
                direction: .up, greyedOutPositions: moveResult.greyedOutPositions, gameResult: .unknown
        )
        gameViewController.currentBoardDisplayer.animateMoveResult(moveResultWithUnknownGameResult)
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("OK", action: {})
        _ = alert.showWarning("Oops!".localized, subTitle: String(format: "%@ disconnected from the game.".localized, peerID.displayName))
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard data.count > 0 else { return }

        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else { return }
            let moveResult: MoveResult

            switch DataCodes(rawValue: data[0]) {
            case .moveLeft?:
                moveResult = self.gameViewController.game.moveLeft()
            case .moveDown?:
                moveResult = self.gameViewController.game.moveDown()
            case .moveUp?:
                moveResult = self.gameViewController.game.moveUp()
            case .moveRight:
                moveResult = self.gameViewController.game.moveRight()
            default:
                return
            }

            self.gameViewController.currentBoardDisplayer.animateMoveResult(moveResult)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }


}