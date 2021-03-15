import Foundation

extension Game {
    func createCopy() -> Game {
        Game(game: self)
    }

    func player(_ color: Color) -> Player {
        players.filter { $0.color == color }.first!
    }

    func opponents(to color: Color) -> [Color] {
        players.filter { $0.color != color }.map { $0.color }
    }

    func moveInDirection(_ direction: Direction) {
        switch direction {
        case .up: moveUp()
        case .down: moveDown()
        case .left: moveLeft()
        case .right: moveRight()
        }
    }
}

public class GameAI {
    var gameStates: [Game]
    var game: Game {
        gameStates.last!
    }
    let wSelfLife: Int
    //    let wOpponentLifeLoss: Int
    let wDiffLives: Int
    let wSquareThreshold: Int
    let wSelfSpreadBelowThreshold: Int
    let wSelfSpreadAboveThreshold: Int
    let wOpponentSpread: Int
    let wSelfInDanger: Int
    let wOpponentInDangerBelowThreshold: Int
    let wOpponentInDangerAboveThreshold: Int
    let searchDepth = 6

    let myColor: Color

}
