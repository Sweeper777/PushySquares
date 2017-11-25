import UIKit
import SwiftyAnimate
import SwiftyButton
import SCLAlertView

class GameViewController: UIViewController, GameDelegate {
    
    var playerCount: Int!
    var map: Map = .standard

    @IBOutlet var boardView: GameBoardView!
    @IBOutlet var statusBar: StatusBar!
    var game: Game!
    
    var swipeUpGR: UISwipeGestureRecognizer!
    var swipeDownGR: UISwipeGestureRecognizer!
    var swipeLeftGR: UISwipeGestureRecognizer!
    var swipeRightGR: UISwipeGestureRecognizer!
    
    var quitButton: PressableButton?
    var restartButton: PressableButton?
    
    var tapGR: UITapGestureRecognizer!
    
    var allGR: [UIGestureRecognizer] {
        return [swipeUpGR, swipeDownGR, swipeRightGR, swipeLeftGR]
    }
    
    func newGame() -> Game {
        return Game(map: map, playerCount: playerCount)
    }
    
    override func viewDidLoad() {
        
        game = newGame()
        
        repositionViews(size: self.view.frame.size)
        
        boardView.game = self.game
        
        game.delegate = self
        
        swipeUpGR = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeDownGR = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeLeftGR = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeRightGR = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        tapGR = UITapGestureRecognizer(target: self, action: #selector(showHideActionBar))
        swipeUpGR.direction = .up
        swipeDownGR.direction = .down
        swipeLeftGR.direction = .left
        swipeRightGR.direction = .right
        
        allGR.forEach { self.view.addGestureRecognizer($0) }
        self.view.addGestureRecognizer(tapGR)
        
        self.statusBar.setNewSquareIn(value: self.game.currentPlayer.turnsUntilNewSquare)
        self.statusBar.setCurrentTurn(value: self.game.currentPlayer.color)
        self.statusBar.setLives(players: self.game.players)
    }
    
    func swipedUp() {
        game.moveUp()
    }
    
    func swipedDown() {
        game.moveDown()
    }
    
    func swipedLeft() {
        game.moveLeft()
    }
    
    func swipedRight() {
        game.moveRight()
    }
    
    
    
    func playerDidMakeMove(direction: Direction?, originalPositions: [Position], destroyedSquarePositions: [Position], greyedOutPositions: [Position], newSquareColor: Color?) {
        var moveAnim = Animate()
        
        for position in originalPositions {
            let squareView = boardView.viewWithTag(position.hashValue) as! SquareView
            let squareViewMove: Animate
            switch direction! {
            case .down:
                squareViewMove = squareView.moveDown
            case .up:
                squareViewMove = squareView.moveUp
            case .left:
                squareViewMove = squareView.moveLeft
            case .right:
                squareViewMove = squareView.moveRight
            }
            moveAnim = moveAnim.and(animation: squareViewMove)
        }
        
        var destroyedAnim = Animate()
        for position in destroyedSquarePositions {
            let squareView = boardView.viewWithTag(position.hashValue) as! SquareView
            destroyedAnim = destroyedAnim.and(animation: squareView.destroyed)
        }
        moveAnim = moveAnim.then(animation: destroyedAnim)
        
        var greyOutAnim = Animate()
        for position in greyedOutPositions {
            let squareView = boardView.viewWithTag(position.hashValue) as! SquareView
            greyOutAnim = greyOutAnim.and(animation: squareView.greyOut)
        }
        moveAnim = moveAnim.then(animation: greyOutAnim)
        
        var winnerColor: Color?
        
        if let color = newSquareColor {
            if color == .grey {
                winnerColor = .grey
            } else {
                boardView.addSquareView(at: game.spawnpoints[color]!, color: GameBoardView.colorToUIColor[color]!)
                let squareView = boardView.viewWithTag(game.spawnpoints[color]!.hashValue) as! SquareView
                squareView.alpha = 0
                moveAnim = moveAnim.then(animation: squareView.appear)
            }
        }
        
        let remainingPlayers = game.players.filter({ $0.lives > 0 })
        if remainingPlayers.count == 1 {
            winnerColor = remainingPlayers.first!.color
        } else if remainingPlayers.count == 0 {
            winnerColor = .grey
        }
        
        allGR.forEach { $0.isEnabled = false }
        moveAnim.perform() {
            [weak self] in
            guard let `self` = self else { return }
            self.allGR.forEach { $0.isEnabled = true }
            self.statusBar.setNewSquareIn(value: self.game.currentPlayer.turnsUntilNewSquare)
            self.statusBar.setCurrentTurn(value: self.game.currentPlayer.color)
            if destroyedSquarePositions.isNotEmpty {
                self.statusBar.setLives(players: self.game.players)
            }
            
            var closure: ((Position) -> Position) = { $0 }
            if let dir = direction {
                switch dir {
                case .down:
                    closure = {$0.below()}
                case .up:
                    closure = {$0.above()}
                case .left:
                    closure = {$0.left()}
                case .right:
                    closure = {$0.right()}
                }
            }
            for position in destroyedSquarePositions.map(closure) {
                self.boardView.viewWithTag(position.hashValue)!.removeFromSuperview()
            }
                
            if let color = winnerColor {
                self.allGR.forEach { $0.isEnabled = false }
                let winnerUIColor = GameBoardView.colorToUIColor[color]!
                let message: String
                switch color {
                case .grey:
                    message = "It's a draw"
                default:
                    message = "\(GameBoardView.colorToString[color]!) is the winner!"
                }
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 56, height: 56), false, 0)
                winnerUIColor.setFill()
                UIRectFill(CGRect.zero.with(width: 56).with(height: 56))
                let image = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(kCircleIconHeight: 56, showCloseButton: false))
                alert.addButton("OK", action: {})
                _ = alert.showCustom(message, subTitle: "", color: .black, icon: image)
            }
            self.boardView.setNeedsDisplay()
            self.animationDidComplete()
        }
    }
    
    func animationDidComplete() {
        
    }
    
    func repositionViews(size: CGSize) {
        view.subviews.forEach { $0.removeFromSuperview() }
        let separator = 8.f
        let statusBarWeight = 13.f / 84.f
        if size.height > size.width {
            let statusBarHeight = (size.height - 7 * separator) * statusBarWeight
            let statusBarWidth = size.width  - 2 * separator
            statusBar = StatusBar(frame: CGRect(x: separator, y: separator * 3, width: statusBarWidth, height: statusBarHeight))
            view.addSubview(statusBar)
            self.statusBar.setNewSquareIn(value: self.game.currentPlayer.turnsUntilNewSquare)
            self.statusBar.setCurrentTurn(value: self.game.currentPlayer.color)
            self.statusBar.setLives(players: self.game.players)
            
            let heightLeft = size.height - (separator * 7 + statusBarHeight)
            let widthLeft = size.width - separator * 2
            let boardLength = min(heightLeft, widthLeft)
            let centerY = 6 * separator + statusBarHeight + heightLeft / 2
            let centerX = size.width / 2
            boardView = GameBoardView(frame: CGRect(origin: .zero, size: CGSize(width: boardLength, height: boardLength)))
            boardView.game = self.game
            boardView.center = CGPoint(x: centerX, y: centerY)
            boardView.backgroundColor = .clear
            view.addSubview(boardView)
        } else {
            let statusBarWidth = (size.width - 7 * separator) * statusBarWeight
            let statusBarHeight = size.height - 2 * separator
            statusBar = StatusBar(frame: CGRect(x: separator * 3, y: separator, width: statusBarWidth, height: statusBarHeight))
            (statusBar.subviews.first! as! UIStackView).axis = .vertical
            view.addSubview(statusBar)
            self.statusBar.setNewSquareIn(value: self.game.currentPlayer.turnsUntilNewSquare)
            self.statusBar.setCurrentTurn(value: self.game.currentPlayer.color)
            self.statusBar.setLives(players: self.game.players)
            
            let widthLeft = size.width - (separator * 7 + statusBarWidth)
            let heightLeft = size.height - separator * 2
            let boardLength = min(heightLeft, widthLeft)
            let centerX = 6 * separator + statusBarWidth + widthLeft / 2
            let centerY = size.height / 2
            boardView = GameBoardView(frame: CGRect(origin: .zero, size: CGSize(width: boardLength, height: boardLength)))
            boardView.game = self.game
            boardView.center = CGPoint(x: centerX, y: centerY)
            boardView.backgroundColor = .clear
            view.addSubview(boardView)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        repositionViews(size: size)
    }
    
    func showHideActionBar() {
        
        if let quitButton = self.quitButton, let restartButton = self.restartButton {
            UIView.animate(withDuration: 0.25, animations: {
                quitButton.alpha = 0
                restartButton.alpha = 0
            }, completion: {
                if $0 {
                    restartButton.removeFromSuperview()
                    quitButton.removeFromSuperview()
                }
            })
            self.quitButton = nil
            self.restartButton = nil
        } else {
            let actionBarButtonLength = min(self.view.width, self.view.height) / 8
            let actionBarYWeight = 0.7.f
            let separatorLength = self.view.width / 3
            let actionBarY = self.view.height * actionBarYWeight
            let actionBarX = self.view.width / 2 - separatorLength / 2 - actionBarButtonLength
            quitButton = PressableButton()
            quitButton!.frame = CGRect(x: actionBarX, y: actionBarY, width: actionBarButtonLength, height: actionBarButtonLength)
            quitButton!.shadowHeight = quitButton!.height * 0.1
            quitButton!.colors = PressableButton.ColorSet(button: UIColor.gray.desaturated(), shadow: UIColor.gray.desaturated().darker())
            
            let fontSize = fontSizeThatFits(size: quitButton!.frame.size, text: "↺", font: UIFont.systemFont(ofSize: 0))
            quitButton!.setAttributedTitle(
                NSAttributedString.init(string: "×", attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
                    NSForegroundColorAttributeName: UIColor.white
                    ]), for: .normal)
            
            quitButton!.alpha = 0
            quitButton!.addTarget(self, action: #selector(quitTapped), for: .touchUpInside)
            restartButton = PressableButton()
            restartButton!.frame = CGRect(x: actionBarX + actionBarButtonLength + separatorLength, y: actionBarY, width: actionBarButtonLength, height: actionBarButtonLength)
            restartButton!.shadowHeight = restartButton!.height * 0.1
            restartButton!.colors = PressableButton.ColorSet(button: UIColor.gray.desaturated(), shadow: UIColor.gray.desaturated().darker())
            restartButton!.setAttributedTitle(
                NSAttributedString.init(string: "↺", attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: fontSize * 0.8),
                    NSForegroundColorAttributeName: UIColor.white
                    ]), for: .normal)
            restartButton!.alpha = 0
            restartButton!.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
            self.view.addSubview(restartButton!)
            self.view.addSubview(quitButton!)
            UIView.animate(withDuration: 0.25, animations: {
                [weak self] in
                self?.quitButton!.alpha = 1
                self?.restartButton!.alpha = 1
            })
        }
    }
    
    func quitTapped() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Yes", action: {
            [weak self] in
            guard let `self` = self else { return }
            self.performSegue(withIdentifier: "quitGame", sender: self)
        })
        alert.addButton("No", action: {})
        alert.showWarning("Confirm", subTitle: "Do you really want to quit?")
    }
    
    func restartTapped() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Yes", action: {
            [weak self] in
            guard let `self` = self else { return }
            self.game = self.newGame()
            self.game.delegate = self
            self.boardView.game = self.game
            self.statusBar.setNewSquareIn(value: self.game.currentPlayer.turnsUntilNewSquare)
            self.statusBar.setCurrentTurn(value: self.game.currentPlayer.color)
            self.statusBar.setLives(players: self.game.players)
            self.allGR.forEach { $0.isEnabled = true }
            self.showHideActionBar()
        })
        alert.addButton("No", action: {})
        alert.showWarning("Confirm", subTitle: "Do you really want to restart?")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        repositionViews(size: view.frame.size)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

