import PushySquaresModel

let game = Game(map: .standard, playerCount: 2)
printBoard(game.map, state: game.boardState)
for _ in 0..<100 {
    let ai = GameAI(game: Game(game: game), myColor: game.currentPlayer.color,
                    [9817,3256,2,6212,3272,4225,6744,2582,5886])
    switch ai.getNextMove() {
    case .down:
        game.moveDown()
    case .left:
        game.moveLeft()
    case .right:
        game.moveRight()
    case .up:
        game.moveUp()
    }
    printBoard(game.map, state: game.boardState)
}
