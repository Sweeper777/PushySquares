import Foundation

public struct MoveResult {
    public let direction: Direction
    public let movedPositions: [Position]
    public let slippedPositions: [Position]
    public let fellPositions: [Position]
    public let greyedOutPositions: [Position]
    public let newSquareColor: Color?

    init(direction: Direction,
         movedPositions: [Position] = [],
         slippedPositions: [Position] = [],
         fellPositions: [Position] = [],
         greyedOutPositions: [Position] = [],
         newSquareColor: Color? = nil) {
        self.direction = direction
        self.movedPositions = movedPositions
        self.slippedPositions = slippedPositions
        self.fellPositions = fellPositions
        self.greyedOutPositions = greyedOutPositions
        self.newSquareColor = newSquareColor
    }
}
