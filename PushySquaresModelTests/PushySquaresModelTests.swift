import XCTest
@testable import PushySquaresModel

class PushySquaresModelTests: XCTestCase {

    func testMap() throws {
        let map = Map.standard
        XCTAssertEqual(map.spawnpoints.count, 4)
        XCTAssertTrue(map.board.contains { $0 == .wall })
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
