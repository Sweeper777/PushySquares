import UIKit
import PushySquaresModel
import SwiftyButton

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

        setupStackView()
    }

    func makeMenuButtons() -> [UIView] {
        let quitButton = PressableButton()
        let buttonHeight = 40.f
        quitButton.shadowHeight = buttonHeight * 0.1
        quitButton.colors = PressableButton.ColorSet(button: UIColor.gray.desaturated(), shadow: UIColor.gray.desaturated().darker())
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        quitButton.tintColor = .white
        quitButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        quitButton.addTarget(self, action: #selector(quitTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            quitButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            quitButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])

        let restartButton = PressableButton()
        restartButton.shadowHeight = buttonHeight * 0.1
        restartButton.colors = PressableButton.ColorSet(button: UIColor.gray.desaturated(), shadow: UIColor.gray.desaturated().darker())
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.tintColor = .white
        restartButton.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)

        NSLayoutConstraint.activate([
            restartButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            restartButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])

        return [quitButton, restartButton]
    }

    func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: makeMenuButtons())
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        stackView.spacing = 16
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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

    @objc func quitTapped() {

    }

    @objc func restartGame() {
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
