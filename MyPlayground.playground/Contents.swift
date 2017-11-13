import PushySquaresModel
import UIKit

let game = Game(map: .standard, playerCount: 4)
game.moveDown()
game.moveDown()
printBoard(game.board)