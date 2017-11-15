import UIKit

class AIGameViewController: GameViewController {
    var aiCount: Int!
    var playerColors: [Color]!
    
    override func newGame() -> Game {
        let game = Game(map: .standard, playerCount: playerCount + aiCount)
        var colors = game.players.map { $0.color }
        playerColors = []
        for _ in 0..<playerCount {
            playerColors.append(randomFromArrayAndRemove(&colors))
        }
        return game
    }
    
    override func animationDidComplete() {
        if !self.playerColors.contains(self.game.currentPlayer.color) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if !self.playerColors.contains(self.game.currentPlayer.color) {
                self.allGR.forEach { $0.isEnabled = false }
                let ai = GameAI(game: self.game.createCopy(), myColor: self.game.currentPlayer.color, wSelfLife: 553, wDiffLives: 8371, wSquareThreshold: 3, wSelfSpreadBelowThreshold: 5646, wSelfSpreadAboveThreshold: 3791, wOpponentSpread: 8583, wSelfInDanger: 6187, wOpponentInDangerBelowThreshold: 680, wOpponentInDangerAboveThreshold: 9157)
                self.game.moveInDirection(ai.getNextMove())
            }
        }
    }
}

func randomFromArrayAndRemove<T>(_ a: inout [T]) -> T {
    let randomNumber = Int(arc4random_uniform(UInt32(a.count)))
    let item = a[randomNumber]
    a.remove(at: randomNumber)
    return item
}
