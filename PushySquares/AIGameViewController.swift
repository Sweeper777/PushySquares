import PushySquaresModel
import UIKit
import SCLAlertView

class AIGameViewController : GameViewController {
    var hasHumanPlayer = true
    var humanPlayerColor: Color?
    let aiQueue = DispatchQueue(label: "gameAI", qos: .userInitiated)
    var currentAI: GameAI?

    override func restartGame() {
        super.restartGame()
        if hasHumanPlayer {
            humanPlayerColor = Color.allCases.randomElement()
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(kCircleIconHeight: 56, showCloseButton: false))
            alert.addButton("OK", action: {})
            _ = alert.showCustom(
                    String(format: "Your color is %@.".localized, BoardView.colorToString[humanPlayerColor!]!),
                    subTitle: "", color: .black,
                    icon: BoardView.colorToUIColor[humanPlayerColor!]!.image(size: CGSize(width: 56, height: 56)))
        } else {
            humanPlayerColor = nil
        }
        tryAIMove()
    }

    var isAITurn: Bool {
        game.currentPlayer.color != humanPlayerColor
    }

}
