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
