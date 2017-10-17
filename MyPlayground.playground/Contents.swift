import PushySquaresModel
import UIKit

/*
Heuristic Evaluation Function Algorithm:
 - life loss, if >= current lives then -inf, -1 each * 1000
 - opponent life loss, if 2 players left, difference between after self life and after opponent life * 10000, otherwise +1 each * 1000
 - spread (max of maxX and maxY), -1 each * 100 if squares < 4 else 1
 - opponent spread, +1 each * 1 if squares < 4, else 10
 - in danger (be pushed off next), -1 each * 100 if current life > count, else inf
 - opponent in danger, +1 each * 1 if squares < 4, else 100
*/

func printBoard(_ board: Array2D<Tile>) {
    for y in 0..<board.columns {
        for x in 0..<board.rows {
            switch board[x, y] {
            case .empty:
                print("⬜️", separator: "", terminator: "")
            case .wall:
                print("🔲", separator: "", terminator: "")
            case .void:
                print("▫️", separator: "", terminator: "")
            case .square(let color):
                switch color {
                case .color1:
                    print("🚹", separator: "", terminator: "")
                case .color2:
                    print("🚺", separator: "", terminator: "")
                case .color3:
                    print("🚼", separator: "", terminator: "")
                case .color4:
                    print("❇️", separator: "", terminator: "")
                case .grey:
                    print("ℹ️", separator: "", terminator: "")
                }
            }
        }
        print("")
    }
}

let game = Game(map: .standard, playerCount: 4)
