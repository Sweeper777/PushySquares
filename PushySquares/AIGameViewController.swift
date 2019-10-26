import UIKit
import SCLAlertView

class AIGameViewController: GameViewController {
    var aiCount: Int!
    var playerColors: [Color]!
    var aiQueue = DispatchQueue(label: "gameAI")
    var currentAI: GameAI!
    
    var shouldRestart = false
    
    override func newGame() -> Game {
        let game = Game(map: map, playerCount: playerCount + aiCount)
        var colors = game.players.map { $0.color }
        playerColors = []
        for _ in 0..<playerCount {
            playerColors.append(randomFromArrayAndRemove(&colors))
        }
        return game
    }
    
    override func animationDidComplete() {
        if shouldRestart {
            restart()
            shouldRestart = false
            return
        }
        if !self.playerColors.contains(self.game.currentPlayer.color) {
            allGR.forEach { $0.isEnabled = false }
            let livingPlayersCount = game.players.filter({$0.lives > 0}).count
            if livingPlayersCount > 1 {
                currentAI = livingPlayersCount == 2 ? self.twoPlayerAI() : self.multiplayerAI()
                currentAI.getNextMove(on: aiQueue)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.playerColors.contains(self.game.currentPlayer.color) {
            self.allGR.forEach { $0.isEnabled = false }
            currentAI = self.aiCount < 2 ? self.twoPlayerAI() : self.multiplayerAI()
            currentAI.getNextMove(on: aiQueue)
        }
        if let myColor = playerColors.first {
            let color = GameBoardView.colorToUIColor[myColor]!
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 56, height: 56), false, 0)
            color.setFill()
            UIRectFill(CGRect.zero.with(width: 56).with(height: 56))
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(kCircleIconHeight: 56, showCloseButton: false))
            alert.addButton("OK", action: {})
            _ = alert.showCustom(String(format: "Your color is %@.".localized, GameBoardView.colorToString[myColor]!), subTitle: "", color: .black, icon: image)
        }
    }
    
    override func restartTapped() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Yes".localized, action: {
            [weak self] in
            guard let `self` = self else { return }
            if self.playerColors.contains(self.game.currentPlayer.color) {
                self.restart()
            } else {
                self.shouldRestart = true
            }
        })
        alert.addButton("No".localized, action: {})
        alert.showWarning("Confirm".localized, subTitle: "Do you really want to restart?".localized)
    }
    
    func restart() {
        self.game.delegate = nil
        self.currentAI = nil
        self.game = self.newGame()
        self.game.delegate = self
        self.boardView.game = self.game
        self.statusBar.setNewSquareIn(value: self.game.currentPlayer.turnsUntilNewSquare)
        self.statusBar.setCurrentTurn(value: self.game.currentPlayer.color)
        self.statusBar.setLives(players: self.game.players)
        if let myColor = self.playerColors.first {
            let color = GameBoardView.colorToUIColor[myColor]!
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 56, height: 56), false, 0)
            color.setFill()
            UIRectFill(CGRect.zero.with(width: 56).with(height: 56))
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(kCircleIconHeight: 56, showCloseButton: false))
            alert.addButton("OK".localized, action: {})
            _ = alert.showCustom(String(format: "Your color is %@.".localized, GameBoardView.colorToString[myColor]!), subTitle: "", color: .black, icon: image)
        }
        if self.playerColors.contains(self.game.currentPlayer.color) {
            self.allGR.forEach { $0.isEnabled = true }
        } else {
            self.allGR.forEach { $0.isEnabled = false }
            DispatchQueue.main.async {
                self.currentAI = self.aiCount < 2 ? self.twoPlayerAI() : self.multiplayerAI()
                self.currentAI.getNextMove(on: self.aiQueue)
            }
        }
        self.showHideActionBar()
    }
    
    fileprivate func twoPlayerAI() -> GameAI {
        let ai = GameAI(game: self.game.createCopy(), myColor: self.game.currentPlayer.color, wSelfLife: 553, wDiffLives: 8371, wSquareThreshold: 3, wSelfSpreadBelowThreshold: 5646, wSelfSpreadAboveThreshold: 3791, wOpponentSpread: 8583, wSelfInDanger: 6187, wOpponentInDangerBelowThreshold: 680, wOpponentInDangerAboveThreshold: 9157)
        ai.delegate = self
        return ai
    }
    
    fileprivate func multiplayerAI() -> GameAI {
        let ai = GameAI(game: self.game.createCopy(), myColor: self.game.currentPlayer.color, multiplayerAIArrays[Int(arc4random_uniform(UInt32(multiplayerAIArrays.count)))])
        ai.delegate = self
        return ai
    }
}

extension AIGameViewController: GameAIDelegate {
    func gameAIDidMakeMove(direction: Direction) {
        DispatchQueue.main.async {
            self.game.moveInDirection(direction)
        }
    }
}

func randomFromArrayAndRemove<T>(_ a: inout [T]) -> T {
    let randomNumber = Int(arc4random_uniform(UInt32(a.count)))
    let item = a[randomNumber]
    a.remove(at: randomNumber)
    return item
}

extension GameAI {
    convenience init(game: Game, myColor: Color, _ arr: [Int]) {
        self.init(game: game, myColor: myColor, wSelfLife: arr[0], wDiffLives: arr[1], wSquareThreshold: arr[2], wSelfSpreadBelowThreshold: arr[3], wSelfSpreadAboveThreshold: arr[4], wOpponentSpread: arr[5], wSelfInDanger: arr[6], wOpponentInDangerBelowThreshold: arr[7], wOpponentInDangerAboveThreshold: arr[8])
    }
}
