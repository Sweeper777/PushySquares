import Foundation

public struct Map {
    public let board: Array2D<Tile>
    public let spawnpoints: [Color: Position]
    public let slipperyPositions: [Position]
    
    public static let standard = Map(file: Bundle.main.path(forResource: "standard", ofType: "map")!)
    
    public init(board: Array2D<Tile>, spawnpoints: [Color: Position], slipperyPositions: [Position]) {
        self.board = board
        self.spawnpoints = spawnpoints
        self.slipperyPositions = slipperyPositions
    }
    
    public init(file path: String) {
        let fileContents = try! String(contentsOfFile: path)
        let dict: [Character: Tile] = [
            ".": .void,
            "+": .empty,
            "O": .wall,
            "g": .square(.grey)
        ]
        let lines = fileContents.components(separatedBy: "\n").filter({!$0.isEmpty})
        var board = Array2D<Tile>(columns: lines.first!.count, rows: lines.count, initialValue: .void)
        var spawnpoints = [Color: Position]()
        var slipperyPositions = [Position]()
        for (x, line) in lines.enumerated() {
            for (y, c) in line.enumerated() {
                board[x, y] = dict[c] ?? .empty
                switch c {
                case "1":
                    spawnpoints[.color1] = Position(x, y)
                case "2":
                    spawnpoints[.color2] = Position(x, y)
                case "3":
                    spawnpoints[.color3] = Position(x, y)
                case "4":
                    spawnpoints[.color4] = Position(x, y)
                case "s":
                    slipperyPositions.append(Position(x, y))
                default: break
                }
            }
        }
        self.board = board
        self.spawnpoints = spawnpoints
        self.slipperyPositions = slipperyPositions
    }
}

public func printBoard(_ board: Array2D<Tile>) {
    for y in 0..<board.columns {
        for x in 0..<board.rows {
            switch board[x, y] {
            case .empty:
                print("⬜️", separator: "", terminator: "")
            case .wall:
                print("🔲", separator: "", terminator: "")
            case .void:
                print("▫️", separator: "", terminator: "")
            case .square(let color):
                switch color {
                case .color1:
                    print("🚹", separator: "", terminator: "")
                case .color2:
                    print("🚺", separator: "", terminator: "")
                case .color3:
                    print("🚼", separator: "", terminator: "")
                case .color4:
                    print("❇️", separator: "", terminator: "")
                case .grey:
                    print("ℹ️", separator: "", terminator: "")
                }
            }
        }
        print("")
    }
}

let allMaps = ["standard", "small", "large", "hole", "walls", "zigzag", "quick", "grey1", "grey2", "grey3", "diagonal", "slippery"]

