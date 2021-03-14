public class Game {
    static let playerCountToTurnsUntilNewSquare = [
        2: 2,
        3: 4,
        4: 4
    ]
    
    public let map: Array2D<MapTile>
    public private(set) var boardState: Array2D<BoardState>
    public private(set) var spawnpoints: [Color: Position]
    public private(set) var players = [Player]()
    public var currentPlayer: Player {
        return players[currentPlayerIndex]
    }
    
    private var currentPlayerIndex = 0
    
    public init(map: Map, playerCount: Int, lives: Int = 5) {
        self.map = map.board
        self.boardState = map.initialBoardState
        self.spawnpoints = map.spawnpoints
        
        switch playerCount {
        case 4:
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .yellow))
            spawnNewSquare(color: .yellow)
            fallthrough
        case 3:
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .blue))
            spawnNewSquare(color: .blue)
            fallthrough
        case 2:
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .red))
            players.append(Player(turnsUntilNewSquare: Game.playerCountToTurnsUntilNewSquare[playerCount]!, lives: lives, color: .green))
            spawnNewSquare(color: .red)
            spawnNewSquare(color: .green)
        default:
            fatalError()
        }
        
        players.sort { $0.color.rawValue < $1.color.rawValue }
        
        if playerCount < 4 {
            spawnpoints[.yellow] = nil
        }
        
        if playerCount < 3 {
            spawnpoints[.blue] = nil
        }
        
        currentPlayer.turnsUntilNewSquare -= 1
    }
    
    public init(game: Game) {
        self.boardState = game.boardState
        self.map = game.map
        self.spawnpoints = game.spawnpoints
        self.players = game.players.map { $0.createCopy() }
        self.currentPlayerIndex = game.currentPlayerIndex
    }
    
    public func killPlayer(_ color: Color) {
        guard let index = players.firstIndex(where: { $0.color == color && $0.lives > 0 }) else { return }
        let player = players[index]
        player.lives = 0
        var greyedOutPositions = [Position]()
        for position in boardState.indices(ofColor: color) {
            boardState[position] = .deadBody
            greyedOutPositions.append(position)
        }
        
        if currentPlayer.color == color {
            nextTurn()
        }
        
    }
    
    private func nextTurn() {
        if (!players.contains { $0.lives > 0 }) {
            return
        }
        
        repeat {
            currentPlayerIndex = currentPlayerIndex == players.endIndex - 1 ? 0 : currentPlayerIndex + 1
        } while currentPlayer.lives == 0
    }

    private func evaluateTurnsUntilNewSquare() -> Color? {
        currentPlayer.turnsUntilNewSquare -= 1
        if currentPlayer.turnsUntilNewSquare == 0 {
            if boardState[spawnpoints[currentPlayer.color]!] == .empty {
                spawnNewSquare(color: currentPlayer.color)
                currentPlayer.turnsUntilNewSquare = Game.playerCountToTurnsUntilNewSquare[players.count]! + 1
                return currentPlayer.color
            }
            currentPlayer.turnsUntilNewSquare = Game.playerCountToTurnsUntilNewSquare[players.count]! + 1
        }
        return nil
    }
    
    private func canSlip(in direction: Direction, position: Position) -> SlipResult {
        let displace = direction.displacementFunction
        let displaced = displace(position)
        if map[displaced] == .slippery || boardState[displaced].isSquare {
            return .fail
        }
        if let slippedState = boardState[safe: displace(displaced)],
           let slippedMapTile = map[safe: displace(displaced)] {
            switch (slippedMapTile, slippedState) {
            case (.void, _):
                return .death
            case (.wall, _), (_, .square), (_, .deadBody):
                return .fail
            default:
                return .success
            }
        } else {
            return .fail
        }
    }
    
    func isEdge(position: Position) -> [Direction] {
        var directions = [Direction]()
        if case .void = map[position.above()] {
            directions.append(.up)
        }
        if case .void = map[position.below()] {
            directions.append(.down)
        }
        if case .void = map[position.left()] {
            directions.append(.left)
        }
        if case .void = map[position.right()] {
            directions.append(.right)
        }
        return directions
    }

    private func spawnNewSquare(color: Color) {
        boardState[spawnpoints[color]!] = .square(color)
    }
    
    enum SlipResult {
        case success
        case fail
        case death
    }
}
