public enum BoardState : Equatable {
    case empty
    case square(Color)
    case deadBody
    
    public var isSquare: Bool {
        if case .square = self {
            return true
        }
        return false
    }
}
