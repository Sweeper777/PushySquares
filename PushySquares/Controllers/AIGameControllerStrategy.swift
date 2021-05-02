import PushySquaresModel
import UIKit
import SCLAlertView

class AIGameControllerStrategy : GameControllerStrategy {

    private unowned var gameViewController: GameViewController
    var hasHumanPlayer = true
    var humanPlayerColor: Color?
    let aiQueue = DispatchQueue(label: "gameAI", qos: .userInitiated)
    var currentAI: GameAI?

    init(gameViewController: GameViewController) {
        self.gameViewController = gameViewController
    }

    func didRestartGame() {
        if hasHumanPlayer {
            humanPlayerColor = gameViewController.game.players.randomElement()?.color
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(kCircleIconHeight: 56, showCloseButton: false))
            alert.addButton("OK".localized, action: {})
            _ = alert.showCustom(
                    String(format: "Your color is %@.".localized, BoardView.colorToString[humanPlayerColor!]!),
                    subTitle: "", color: .black,
                    icon: BoardView.colorToUIColor[humanPlayerColor!]!.image(size: CGSize(width: 56, height: 56)))
        } else {
            humanPlayerColor = nil
        }
        tryAIMove()
    }

    func didEndAnimatingMoveResult(_ moveResult: MoveResult) {
        tryAIMove()
    }

    func makeMenuButtons() -> [UIView]? {
        nil
    }

    func willMove(_ direction: Direction) {

    }

    var isAITurn: Bool {
        gameViewController.game.currentPlayer.color != humanPlayerColor
    }

    func tryAIMove() {
        guard isAITurn else {
            gameViewController.setAllowMoves(true)
            return
        }
        gameViewController.setAllowMoves(false)
        guard gameViewController.game.gameResult == .unknown else {
            return
        }

        let weightsArray: [Int]
        if gameViewController.playerCount == 2 {
            weightsArray = twoPlayerAIArray
        } else {
            weightsArray = multiplayerAIArrays.randomElement()!
        }
        let game = gameViewController.game
        currentAI = GameAI(game: Game(game: gameViewController.game), myColor: gameViewController.game.currentPlayer.color, weightsArray)
        currentAI!.getNextMove(on: aiQueue) { [weak self, game] direction in
            guard self?.gameViewController.game === game else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                let moveResult: MoveResult
                switch direction {
                case .up:
                    moveResult = self.gameViewController.game.moveUp()
                case .down:
                    moveResult = self.gameViewController.game.moveDown()
                case .left:
                    moveResult = self.gameViewController.game.moveLeft()
                case .right:
                    moveResult = self.gameViewController.game.moveRight()
                }
                self.gameViewController.currentBoardDisplayer.animateMoveResult(moveResult)
            }
        }
    }
}
