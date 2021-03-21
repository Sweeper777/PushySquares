import PushySquaresModel
enum AnimationType: Hashable {
    case move(dx: Double, dy: Double)
    case fall
    case grayOut
    case newSquare
}
