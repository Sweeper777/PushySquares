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

    func evaluateHeuristics() -> Int {
        let livingPlayers = game.players.filter({ $0.lives > 0 })
        let me = game.player(myColor)
        if me.lives == 0 {
            return Int.min
        }
        if livingPlayers.count == 1 && me.lives > 0 {
            return Int.max
        }
        if livingPlayers.count == 0 {
            return 0
        }
        //        let finalSelfLifeLoss = -lifeLosses[myColor]!
        let finalSelfLives = me.lives
        let opponents = game.opponents(to: myColor)
        let finalDiffLives: Int
        //        let finalOpponentLifeLoss: Int
        if livingPlayers.count == 2 {
            finalDiffLives = me.lives - game.player(opponents[0]).lives
            //            finalOpponentLifeLoss = 0
        } else {
            //            finalOpponentLifeLoss = opponents.map { lifeLosses[$0]! }.reduce(0, +)
            finalDiffLives = 0
        }
        let mySquares = game.boardState.indices(ofColor: myColor)
        let finalSelfSpread = -spread(of: mySquares, pivot: game.spawnpoints[myColor]!)
        let finalOpponentSpread = opponents.map { self.spread(of: self.game.boardState.indices(ofColor: $0), pivot: self.game.spawnpoints[$0]!) }.reduce(0, +) / opponents.count
        let selfInDanger = mySquares.map { self.isInDanger(position: $0, directionsOfEdge: self.game.isEdge(position: $0), myColor: myColor) }.filter{ $0 }.count
        if selfInDanger >= me.lives {
            return Int.min
        }
        let finalSelfInDanger = -selfInDanger
        var opponentInDanger = 0
        for opponent in opponents {
            opponentInDanger += game.boardState.indices(ofColor: opponent).map { self.isInDanger(position: $0, directionsOfEdge: self.game.isEdge(position: $0), myColor: opponent) }.filter{ $0 }.count
        }
        let finalOpponentInDanger = opponentInDanger
        return finalSelfLives * wSelfLife +
                finalDiffLives * wDiffLives +
                finalSelfSpread * (mySquares.count < wSquareThreshold ? wSelfSpreadBelowThreshold : wSelfSpreadAboveThreshold) +
                finalOpponentSpread * wOpponentSpread +
                finalSelfInDanger * wSelfInDanger +
                finalOpponentInDanger * (mySquares.count < wSquareThreshold ? wOpponentInDangerBelowThreshold : wOpponentInDangerAboveThreshold)
    }

}
