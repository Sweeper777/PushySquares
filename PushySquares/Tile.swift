public enum Tile {
    case empty
    case void
    case wall
    case square(Color)
}

public enum Color: Int {
    case color1 = 1
    case color2 = 2
    case color3 = 3
    case color4 = 4
    case grey = 0
}

public enum Direction {
    case up
    case down
    case left
    case right
    
    public var displacementFunction: (Position) -> Position {
        switch self {
        case .up:
            return { $0.above() }
        case .down:
            return { $0.below() }
        case .left:
            return { $0.left() }
        case .right:
            return { $0.right() }
        }
    }
}
