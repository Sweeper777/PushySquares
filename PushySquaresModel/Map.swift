import Foundation

public struct Map {
    public let board: Array2D<MapTile>
    public let initialBoardState: Array2D<BoardState>
    public let spawnpoints: [Color: Position]
    
    public static let standard = Map(file: Bundle.main.path(forResource: "standard", ofType: "map")!)
    
    public init(board: Array2D<MapTile>, initialBoardState: Array2D<BoardState>) {
        self.board = board
        var spawnpoints = [Color: Position]()
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                if case .spawnpoint(let color) = board[x, y] {
                    spawnpoints[color] = Position(x, y)
                }
            }
        }
        self.initialBoardState = initialBoardState
        self.spawnpoints = spawnpoints
    }
    
}
