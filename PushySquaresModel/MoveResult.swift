import Foundation

public struct MoveResult {
    public let direction: Direction
    public let movedPositions: Set<Position>
    public let slippedPositions: Set<Position>
    public let fellPositions: Set<Position>
    public let greyedOutPositions: Set<Position>
    public let newSquare: (Color, Position)?

    init(direction: Direction,
                movedPositions: Set<Position> = [],
                slippedPositions: Set<Position> = [],
                fellPositions: Set<Position> = [],
                greyedOutPositions: Set<Position> = [],
                newSquare: (Color, Position)? = nil) {
        self.direction = direction
        self.movedPositions = movedPositions
        self.slippedPositions = slippedPositions
        self.fellPositions = fellPositions
        self.greyedOutPositions = greyedOutPositions
        self.newSquare = newSquare
    }
}
