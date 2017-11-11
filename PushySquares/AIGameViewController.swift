import UIKit

class AIGameViewController: GameViewController {
    var aiCount: Int!
    
    override func newGame() -> Game {
        return Game(map: .standard, playerCount: playerCount + aiCount)
    }
}
