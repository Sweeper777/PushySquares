

public protocol GameDelegate : class {
    func playerDidMakeMove(originalPositions: [Position], destroyedSquarePositions: [Position], greyedOutPositions: [Position], newSquareColor: Color?)
}
