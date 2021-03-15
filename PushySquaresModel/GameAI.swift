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

    public init(game: Game, myColor: Color, wSelfLife: Int, /*wOpponentLifeLoss: Int,*/ wDiffLives: Int, wSquareThreshold: Int, wSelfSpreadBelowThreshold: Int, wSelfSpreadAboveThreshold: Int, wOpponentSpread: Int, wSelfInDanger: Int, wOpponentInDangerBelowThreshold: Int, wOpponentInDangerAboveThreshold: Int) {
        self.gameStates = [game]
        self.myColor = myColor
        self.wSelfLife = wSelfLife
        //        self.wOpponentLifeLoss = wOpponentLifeLoss
        self.wDiffLives = wDiffLives
        self.wSquareThreshold = wSquareThreshold
        self.wSelfSpreadBelowThreshold = wSelfSpreadBelowThreshold
        self.wSelfSpreadAboveThreshold = wSelfSpreadAboveThreshold
        self.wOpponentSpread = wOpponentSpread
        self.wSelfInDanger = wSelfInDanger
        self.wOpponentInDangerBelowThreshold = wOpponentInDangerBelowThreshold
        self.wOpponentInDangerAboveThreshold = wOpponentInDangerAboveThreshold
    }

    public convenience init(game: Game, myColor: Color, _ arr: [Int]) {
        self.init(game: game, myColor: myColor, wSelfLife: arr[0], wDiffLives: arr[1], wSquareThreshold: arr[2], wSelfSpreadBelowThreshold: arr[3], wSelfSpreadAboveThreshold: arr[4], wOpponentSpread: arr[5], wSelfInDanger: arr[6], wOpponentInDangerBelowThreshold: arr[7], wOpponentInDangerAboveThreshold: arr[8])
    }

}
