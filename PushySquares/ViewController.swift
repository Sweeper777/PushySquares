import UIKit
import PushySquaresModel

class ViewController: UIViewController {

    @IBOutlet var board: BoardView!
    @IBOutlet var statusBar: StatusBar!

    let game = Game(map: .standard, playerCount: 4)

    override func viewDidLoad() {
        super.viewDidLoad()
        board.board = game
        statusBar.setCurrentTurn(game.currentPlayer.color)
        statusBar.setLives(players: game.players)
        statusBar.setNewSquareIn(game.currentPlayer.turnsUntilNewSquare)
    }
}

