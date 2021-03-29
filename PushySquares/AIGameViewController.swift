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

    func tryAIMove() {
        guard isAITurn else {
            setAllGestureRecognisersEnabled(true)
            return
        }
        setAllGestureRecognisersEnabled(false)
        guard game.gameResult == .unknown else {
            return
        }
        let weightsArray: [Int]
        if playerCount > 2 {
            weightsArray = multiplayerAIArrays.randomElement()!
        } else {
            weightsArray = twoPlayerAIArray
        }
        currentAI = GameAI(game: Game(game: game), myColor: game.currentPlayer.color, weightsArray)
        currentAI!.getNextMove(on: aiQueue) { direction in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                let moveResult: MoveResult
                switch direction {
                case .up:
                    moveResult = self.game.moveUp()
                case .down:
                    moveResult = self.game.moveDown()
                case .left:
                    moveResult = self.game.moveLeft()
                case .right:
                    moveResult = self.game.moveRight()
                }
                self.board.animateMoveResult(moveResult)
            }
        }
    }

    override func boardDidEndAnimatingMoveResult(_ moveResult: MoveResult) {
        super.boardDidEndAnimatingMoveResult(moveResult)
        tryAIMove()
    }
}
