public struct Map {
    public let board: Array2D<Tile>
    public let spawnpoints: [Color: Position]
    
    public init(board: Array2D<Tile>, spawnpoints: [Color: Position]) {
        self.board = board
        self.spawnpoints = spawnpoints
    }
}
