import PushySquaresModel
import UIKit
import SCLAlertView

class AIGameViewController : GameViewController {
    var hasHumanPlayer = true
    var humanPlayerColor: Color?
    let aiQueue = DispatchQueue(label: "gameAI", qos: .background)
    var currentAI: GameAI?

}
