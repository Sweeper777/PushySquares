

public protocol GameDelegate : class {
    func squaresDidMove(originalPositions: [Position], destroyedSquarePositions: [Position])
    func squareDidSpawn(color: Color)
    func sqauresDidChangeColor(squaresPositions: [Position], color: Color)
}
