import UIKit

class AIGameViewController: GameViewController {
    var aiCount: Int!
    var playerColors: [Color]!
    
    override func newGame() -> Game {
        return Game(map: .standard, playerCount: playerCount + aiCount)
    }
    
    override func animationDidComplete() {
        if game.currentPlayer.color != .color1 {
            allGR.forEach { $0.isEnabled = false }
            if game.players.filter({$0.lives > 0}).count > 1 {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    let ai = GameAI(game: self.game.createCopy(), myColor: self.game.currentPlayer.color, wSelfLife: 553, wDiffLives: 8371, wSquareThreshold: 3, wSelfSpreadBelowThreshold: 5646, wSelfSpreadAboveThreshold: 3791, wOpponentSpread: 8583, wSelfInDanger: 6187, wOpponentInDangerBelowThreshold: 680, wOpponentInDangerAboveThreshold: 9157)
                    self.game.moveInDirection(ai.getNextMove())
                }
            }
        }
    }
}
