import XCTest
@testable import PushySquaresModel

class PushySquaresModelTests: XCTestCase {

    func testMap() throws {
        let map = Map.standard
        XCTAssertEqual(map.spawnpoints.count, 4)
        XCTAssertTrue(map.board.contains { $0 == .wall })
    }

    func testGamePlayerCount() {
        let game2Player = Game(map: .standard, playerCount: 2)
        XCTAssertEqual(game2Player.spawnpoints.count, 2)
        XCTAssertTrue(game2Player.boardState.contains(where: { $0 == .square(.red) }))
        XCTAssertTrue(game2Player.boardState.contains(where: { $0 == .square(.green) }))

        let game3Player = Game(map: .standard, playerCount: 3)
        XCTAssertEqual(game3Player.spawnpoints.count, 3)
        XCTAssertTrue(game3Player.boardState.contains(where: { $0 == .square(.red) }))
        XCTAssertTrue(game3Player.boardState.contains(where: { $0 == .square(.green) }))
        XCTAssertTrue(game3Player.boardState.contains(where: { $0 == .square(.blue) }))

        let game4Player = Game(map: .standard, playerCount: 4)
        XCTAssertEqual(game4Player.spawnpoints.count, 4)
        XCTAssertTrue(game4Player.boardState.contains(where: { $0 == .square(.red) }))
        XCTAssertTrue(game4Player.boardState.contains(where: { $0 == .square(.green) }))
        XCTAssertTrue(game4Player.boardState.contains(where: { $0 == .square(.blue) }))
        XCTAssertTrue(game4Player.boardState.contains(where: { $0 == .square(.yellow) }))
    }

    func testPlayerTurns() {
        let game = Game(map: .standard, playerCount: 4)
        XCTAssertEqual(game.currentPlayer.color, .red)
        XCTAssertEqual(game.currentPlayer.turnsUntilNewSquare, 3)
        game.moveDown()
        XCTAssertEqual(game.currentPlayer.color, .blue)
        XCTAssertEqual(game.currentPlayer.turnsUntilNewSquare, 3)
        game.moveUp()
        XCTAssertEqual(game.currentPlayer.color, .green)
        XCTAssertEqual(game.currentPlayer.turnsUntilNewSquare, 3)
        game.moveDown()
        XCTAssertEqual(game.currentPlayer.color, .yellow)
        XCTAssertEqual(game.currentPlayer.turnsUntilNewSquare, 3)
        game.moveUp()
        XCTAssertEqual(game.currentPlayer.color, .red)
        XCTAssertEqual(game.currentPlayer.turnsUntilNewSquare, 2)
    }

    func testPlayerDeath() {
        let game = Game(map: .standard, playerCount: 2, lives: 1)
        game.boardState[2, 1] = .square(.red)
        let moveResult = game.moveLeft()
        XCTAssertEqual(game.players.first(where: { $0.color == .red })!.lives, 0)
        XCTAssertEqual(moveResult.movedPositions, [Position(1, 1), Position(2, 1)])
        XCTAssertEqual(moveResult.fellPositions, [Position(1, 1)])
        XCTAssertEqual(moveResult.greyedOutPositions, [Position(1, 1), Position(2, 1)])
        XCTAssertEqual(game.boardState[1, 1], .deadBody)
        XCTAssertEqual(game.boardState[2, 1], .empty)
    }
}
