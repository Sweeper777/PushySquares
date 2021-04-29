import UIKit
import PushySquaresModel
import SwiftyButton
import SCLAlertView
import SceneKit

class GameViewController: UIViewController, BoardDisplayerDelegate {

    @IBOutlet private var board: BoardView!
    @IBOutlet private var sceneView: SCNView!
    @IBOutlet var statusBar: StatusBar!
    var menu: UIStackView!
    private var boardScene: BoardScene!

    var currentBoardDisplayer: BoardDisplayer {
        get {
            in3D ? boardScene! : board!
        }
    }

    var map: Map! = .standard
    var playerCount: Int! = 4
    var game: Game!
    var strategy: GameControllerStrategy!
    var in3D = false {
        didSet {
            guard oldValue != in3D else { return }

            UIView.transition(
                    from: oldValue ? sceneView : board,
                    to: in3D ? sceneView : board,
                    duration: 0.2, options: [.showHideTransitionViews, .transitionFlipFromLeft], completion: nil)
            currentBoardDisplayer.board = game
        }
    }

    private var swipeUpGR: UISwipeGestureRecognizer!
    private var swipeDownGR: UISwipeGestureRecognizer!
    private var swipeLeftGR: UISwipeGestureRecognizer!
    private var swipeRightGR: UISwipeGestureRecognizer!
    private var tapGR: UITapGestureRecognizer!

    private func setupBoards() {
        boardScene = BoardScene()
        boardScene.delegate = self
        board.delegate = self
        boardScene.setup(with: map.map)
        sceneView.scene = boardScene
        sceneView.pointOfView = boardScene.cameraNode
        sceneView.allowsCameraControl = true
        sceneView.defaultCameraController.target = boardScene.cameraPivot
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBoards()

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

        setAllGestureRecognisersEnabled(false)

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

        let threeDButton = PressableButton()
        threeDButton.shadowHeight = buttonHeight * 0.1
        threeDButton.colors = PressableButton.ColorSet(button: UIColor.gray.desaturated(), shadow: UIColor.gray.desaturated().darker())
        threeDButton.translatesAutoresizingMaskIntoConstraints = false
        threeDButton.tintColor = .white
        threeDButton.setImage(UIImage(systemName: "view.3d"), for: .normal)
        threeDButton.addTarget(self, action: #selector(threeDTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            threeDButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            threeDButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])

        return [quitButton, restartButton, threeDButton]
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
        guard !in3D else { return }

        strategy.willMove(.up)
        let moveResult = game.moveUp()
        currentBoardDisplayer.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }

    @objc func swipeDown() {
        guard !in3D else { return }

        strategy.willMove(.down)
        let moveResult = game.moveDown()
        currentBoardDisplayer.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }


    @objc func swipeLeft() {
        guard !in3D else { return }

        strategy.willMove(.left)
        let moveResult = game.moveLeft()
        currentBoardDisplayer.animateMoveResult(moveResult)
        setAllGestureRecognisersEnabled(false)
    }

    @objc func swipeRight() {
        guard !in3D else { return }

        strategy.willMove(.right)
        let moveResult = game.moveRight()
        currentBoardDisplayer.animateMoveResult(moveResult)
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

    @objc func threeDTapped(_ sender: PressableButton) {
        if in3D {
            sender.setImage(UIImage(systemName: "view.3d"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "view.2d"), for: .normal)
        }
        in3D.toggle()
    }

    func restartGame() {
        game = Game(map: map, playerCount: playerCount)
        currentBoardDisplayer.board = game
        setAllGestureRecognisersEnabled(true)
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
            (self.currentBoardDisplayer as? BoardView)?.refreshSubviews()
        }
    }

    func updateStatusBar() {
        statusBar.setNewSquareIn(game.currentPlayer.turnsUntilNewSquare)
        statusBar.setLives(players: game.players)
        statusBar.setCurrentTurn(game.currentPlayer.color)
    }

    func boardDidEndAnimatingMoveResult(_ boardDisplayer: BoardDisplayer, moveResult: MoveResult) {
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
