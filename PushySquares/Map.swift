public struct Map {
    public let board: Array2D<Tile>
    public let spawnpoints: [Color: Position]
    
    public static let standard = Map(board: [
        [.void, .void,  .void,  .void,  .wall,  .wall,  .void,  .void,  .void,  .void,],
        [.void, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .void],
        [.void, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .void],
        [.void, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .void],
        [.wall, .empty, .empty, .empty, .wall,  .wall,  .empty, .empty, .empty, .wall],
        [.wall, .empty, .empty, .empty, .wall,  .wall,  .empty, .empty, .empty, .wall],
        [.void, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .void],
        [.void, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .void],
        [.void, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .void],
        [.void, .void,  .void,  .void,  .wall,  .wall,  .void,  .void,  .void,  .void,]
        ], spawnpoints: [
            .color1: Position(1, 1),
            .color2: Position(8, 1),
            .color3: Position(8, 8),
            .color4: Position(1, 8)
        ])
    
    public init(board: Array2D<Tile>, spawnpoints: [Color: Position]) {
        self.board = board
        self.spawnpoints = spawnpoints
    }
}
