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
    
}
