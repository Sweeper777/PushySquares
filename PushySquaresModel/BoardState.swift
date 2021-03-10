public enum BoardState : Equatable {
    case empty
    case square(Color)
    case deadBody
}
