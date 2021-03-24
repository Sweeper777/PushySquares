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

        let swipeUpGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        let swipeDownGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        let swipeLeftGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        let swipeRightGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))

        swipeUpGR.direction = .up
        swipeDownGR.direction = .down
        swipeLeftGR.direction = .left
        swipeRightGR.direction = .right

        view.addGestureRecognizer(swipeUpGR)
        view.addGestureRecognizer(swipeDownGR)
        view.addGestureRecognizer(swipeLeftGR)
        view.addGestureRecognizer(swipeRightGR)
    }

    @objc func swipeUp() {
        let moveResult = game.moveUp()
        board.animateMoveResult(moveResult)
    }

    @objc func swipeDown() {
        let moveResult = game.moveDown()
        board.animateMoveResult(moveResult)
    }


    @objc func swipeLeft() {
        let moveResult = game.moveLeft()
        board.animateMoveResult(moveResult)
    }

    @objc func swipeRight() {
        let moveResult = game.moveRight()
        board.animateMoveResult(moveResult)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        board.refreshSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.board.refreshSubviews()
        }
    }
}

