import UIKit
import PushySquaresModel
import SwiftyButton
import SCLAlertView

class GameViewController: UIViewController, BoardViewDelegate {

    @IBOutlet var board: BoardView!
    @IBOutlet var statusBar: StatusBar!
    var menu: UIStackView!

    var map: Map! = .standard
    var playerCount: Int! = 4
    var game: Game!
    var strategy: GameControllerStrategy!

    private var swipeUpGR: UISwipeGestureRecognizer!
    private var swipeDownGR: UISwipeGestureRecognizer!
    private var swipeLeftGR: UISwipeGestureRecognizer!
    private var swipeRightGR: UISwipeGestureRecognizer!
    private var tapGR: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        board.delegate = self

        swipeUpGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        swipeDownGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeLeftGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeRightGR = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        tapGR = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))

        swipeUpGR.direction = .up
        swipeDownGR.direction = .down
        swipeLeftGR.direction = .left
        swipeRightGR.direction = .right
        tapGR.numberOfTapsRequired = 1
        tapGR.numberOfTouchesRequired = 1

        view.addGestureRecognizer(swipeUpGR)
        view.addGestureRecognizer(swipeDownGR)
        view.addGestureRecognizer(swipeLeftGR)
        view.addGestureRecognizer(swipeRightGR)
        view.addGestureRecognizer(tapGR)

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
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            restartButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            restartButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])

        return [quitButton, restartButton]
    }

    func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: strategy.makeMenuButtons() ?? makeMenuButtons())
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        stackView.spacing = 16
        stackView.isHidden = true
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        menu = stackView
    }

    func setAllGestureRecognisersEnabled(_ enabled: Bool) {
        swipeUpGR.isEnabled = enabled
        swipeDownGR.isEnabled = enabled
        swipeLeftGR.isEnabled = enabled
        swipeRightGR.isEnabled = enabled
    }

    @objc func swipeUp() {
        strategy.willMove(.up)
        let moveResult = game.moveUp()
        board.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }

    @objc func swipeDown() {
        strategy.willMove(.down)
        let moveResult = game.moveDown()
        board.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }


    @objc func swipeLeft() {
        strategy.willMove(.left)
        let moveResult = game.moveLeft()
        board.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }

    @objc func swipeRight() {
        strategy.willMove(.right)
        let moveResult = game.moveRight()
        board.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }

    @objc func toggleMenu() {
        if menu.isHidden {
            menu.isHidden = false
            menu.alpha = 0
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.menu.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.menu.alpha = 0
            } completion: { [weak self] _ in
                self?.menu.isHidden = true
            }
        }
    }

    @objc func quitTapped() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Yes".localized, action: {
            [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        })
        alert.addButton("No".localized, action: {})
        alert.showWarning("Confirm".localized, subTitle: "Do you really want to quit?".localized)
    }

    @objc func restartTapped() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Yes".localized, action: {
            [weak self] in
            guard let `self` = self else { return }
            self.restartGame()
            self.toggleMenu()
        })
        alert.addButton("No".localized, action: {})
        alert.showWarning("Confirm".localized, subTitle: "Do you really want to restart?".localized)
    }

    func restartGame() {
        game = Game(map: map, playerCount: playerCount)
        board.board = game
        setAllGestureRecognisersEnabled(true)
        board.refreshSubviews()
        updateStatusBar()
        strategy.didRestartGame()
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
            let uiColor = BoardView.colorToUIColor[winningColor]!
            let colorString = BoardView.colorToString[winningColor]!
            showGameResult(message: String(format: "%@ is the winner!".localized, colorString), color: uiColor)
            break
        case .tie:
            showGameResult(message: "It's a draw".localized, color: .gray)
            break
        }
        updateStatusBar()
        strategy.didEndAnimatingMoveResult(moveResult)
    }

    func showGameResult(message: String, color: UIColor) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(kCircleIconHeight: 56, showCloseButton: false))
        alert.addButton("OK".localized, action: {})
        _ = alert.showCustom(message, subTitle: "", color: .black, icon: color.image(size: CGSize(width: 56, height: 56)))
    }
}
