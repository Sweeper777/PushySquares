import Foundation

public struct Map : BoardProvider {
    public var map: Array2D<MapTile> {
        board
    }

    public var boardState: Array2D<BoardState> {
        initialBoardState
    }

    public let board: Array2D<MapTile>
    public let initialBoardState: Array2D<BoardState>
    public let spawnpoints: [Color: Position]
    
    public static let standard = Map(file: Bundle.main.url(forResource: "standard", withExtension: "map")!)
    
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
    
    public init(file url: URL) {
        let fileContents = try! String(contentsOf: url)
        let mapTileDict: [Character: MapTile] = [
            ".": .void,
            "+": .ground,
            "O": .wall,
            "g": .ground,
            "s": .slippery,
            "1": .spawnpoint(for: .red),
            "2": .spawnpoint(for: .blue),
            "3": .spawnpoint(for: .green),
            "4": .spawnpoint(for: .yellow),
        ]
        let boardStateDict: [Character: BoardState] = [
            "g": .deadBody,
        ]
        let lines = fileContents.components(separatedBy: "\n").filter({!$0.isEmpty})
        var board = Array2D<MapTile>(columns: lines.first!.count, rows: lines.count, initialValue: .void)
        var initialState = Array2D<BoardState>(columns: lines.first!.count, rows: lines.count, initialValue: .empty)
        var spawnpoints = [Color: Position]()
        for (x, line) in lines.enumerated() {
            for (y, c) in line.enumerated() {
                board[x, y] = mapTileDict[c] ?? .ground
                initialState[x, y] = boardStateDict[c] ?? .empty
                switch c {
                case "1":
                    spawnpoints[.red] = Position(x, y)
                case "2":
                    spawnpoints[.blue] = Position(x, y)
                case "3":
                    spawnpoints[.green] = Position(x, y)
                case "4":
                    spawnpoints[.yellow] = Position(x, y)
                default: break
                }
            }
        }
        self.board = board
        self.spawnpoints = spawnpoints
        self.initialBoardState = initialState
    }
}

public func printBoard(_ board: Array2D<MapTile>, state: Array2D<BoardState>) {
    for y in 0..<board.columns {
        for x in 0..<board.rows {
            switch (board[x, y], state[x, y]) {
            case (.spawnpoint, .empty), (.ground, .empty):
                print("⬜️", separator: "", terminator: "")
            case (.slippery, .empty):
                print("💦", separator: "", terminator: "")
            case (.wall, _):
                print("🔲", separator: "", terminator: "")
            case (.void, _):
                print("▫️", separator: "", terminator: "")
            case (_, .square(let color)):
                switch color {
                case .red:
                    print("🚹", separator: "", terminator: "")
                case .blue:
                    print("🚺", separator: "", terminator: "")
                case .green:
                    print("🚼", separator: "", terminator: "")
                case .yellow:
                    print("❇️", separator: "", terminator: "")
                }
            case (_, .deadBody):
                print("ℹ️", separator: "", terminator: "")
            }
        }
        print("")
    }
}

public let allMaps = ["standard",
                      "small",
                      "large",
                      "hole",
                      "walls",
                      "zigzag",
                      "quick",
                      "grey1",
                      "grey2",
                      "grey3",
                      "diagonal",
                      "slippery",
                      "superslippery",
                      "morewalls",
                      "cublex1",
                      "cublex2",
                      "cublex3",
                      "cublex4",
                      "cublex5",
]
