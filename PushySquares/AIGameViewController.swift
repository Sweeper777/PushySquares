import PushySquaresModel
import UIKit
import SCLAlertView

class AIGameViewController : GameViewController {
    var hasHumanPlayer = true
    var humanPlayerColor: Color?
    let aiQueue = DispatchQueue(label: "gameAI", qos: .userInitiated)
    var currentAI: GameAI?


    var isAITurn: Bool {
        game.currentPlayer.color != humanPlayerColor
    }

}
