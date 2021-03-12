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
    
}
