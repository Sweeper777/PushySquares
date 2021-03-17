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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
