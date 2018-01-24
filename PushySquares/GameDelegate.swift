

public protocol GameDelegate : class {
    func playerDidMakeMove(direction: Direction?,
                           originalPositions: [Position],
                           slippedPositions: [Position],
                           destroyedSquarePositions: [Position],
                           greyedOutPositions: [Position],
                           newSquareColor: Color?)
}
