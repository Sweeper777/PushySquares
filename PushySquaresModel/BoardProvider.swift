public protocol BoardProvider {
    var map: Array2D<MapTile> { get }
    var boardState: Array2D<BoardState> { get }
}