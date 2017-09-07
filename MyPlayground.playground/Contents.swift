import PushySquaresModel
import UIKit

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
game.moveUp()
game.moveDown()
game.moveDown()
game.moveUp()
game.moveUp()
game.moveDown()
game.moveDown()
game.moveUp()
game.moveUp()
game.moveDown()
game.moveDown()
game.moveUp()
game.moveUp()
game.moveDown()
game.moveRight()
game.moveDown()
game.moveUp()
game.moveDown()
game.moveRight()
game.moveLeft()
game.moveRight()
game.moveUp()
game.moveRight()
game.moveLeft()
game.moveRight()
game.moveDown()
game.moveDown()
game.moveUp()
printBoard(game.board)
