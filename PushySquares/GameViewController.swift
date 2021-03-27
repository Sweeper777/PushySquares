import UIKit
import PushySquaresModel

class GameViewController: UIViewController, BoardViewDelegate {

    @IBOutlet var board: BoardView!
    @IBOutlet var statusBar: StatusBar!

    var map: Map! = .standard
    var playerCount: Int! = 4

    var game: Game!

    private var swipeUpGR: UISwipeGestureRecognizer!
    private var swipeDownGR: UISwipeGestureRecognizer!
    private var swipeLeftGR: UISwipeGestureRecognizer!
    private var swipeRightGR: UISwipeGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        board.delegate = self

        swipeUpGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        swipeDownGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeLeftGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeRightGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))

        swipeUpGR.direction = .up
        swipeDownGR.direction = .down
        swipeLeftGR.direction = .left
        swipeRightGR.direction = .right

        view.addGestureRecognizer(swipeUpGR)
        view.addGestureRecognizer(swipeDownGR)
        view.addGestureRecognizer(swipeLeftGR)
        view.addGestureRecognizer(swipeRightGR)
    }

    func setAllGestureRecognisersEnabled(_ enabled: Bool) {
        swipeUpGR.isEnabled = enabled
        swipeDownGR.isEnabled = enabled
        swipeLeftGR.isEnabled = enabled
        swipeRightGR.isEnabled = enabled
    }

    @objc func swipeUp() {
        let moveResult = game.moveUp()
        board.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }

    @objc func swipeDown() {
        let moveResult = game.moveDown()
        board.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }


    @objc func swipeLeft() {
        let moveResult = game.moveLeft()
        board.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }

    @objc func swipeRight() {
        let moveResult = game.moveRight()
        board.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }

    func restartGame() {
        game = Game(map: map, playerCount: playerCount)
        board.board = game
        setAllGestureRecognisersEnabled(true)
        board.refreshSubviews()
        updateStatusBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restartGame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.board.refreshSubviews()
        }
    }

    func updateStatusBar() {
        statusBar.setNewSquareIn(game.currentPlayer.turnsUntilNewSquare)
        statusBar.setLives(players: game.players)
        statusBar.setCurrentTurn(game.currentPlayer.color)
    }

    func boardDidEndAnimatingMoveResult(_ moveResult: MoveResult) {
        switch moveResult.gameResult {
        case .unknown:
            setAllGestureRecognisersEnabled(true)
        case .won(let winningColor):
            // TODO: handle winning
            break
        case .tie:
            // TODO: handle tie
            break
        }
        updateStatusBar()
    }
}
