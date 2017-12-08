import UIKit
import SCLAlertView

class AIGameViewController: GameViewController {
    var aiCount: Int!
    var playerColors: [Color]!
    
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
        if !self.playerColors.contains(self.game.currentPlayer.color) {
            allGR.forEach { $0.isEnabled = false }
            if game.players.filter({$0.lives > 0}).count > 1 {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    let ai = self.aiCount < 2 ? self.twoPlayerAI() : self.multiplayerAI()
                    self.game.moveInDirection(ai.getNextMove())
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if !self.playerColors.contains(self.game.currentPlayer.color) {
                self.allGR.forEach { $0.isEnabled = false }
                let ai = self.aiCount < 2 ? self.twoPlayerAI() : self.multiplayerAI()
                self.game.moveInDirection(ai.getNextMove())
            }
        }
        let myColor = playerColors.first!
        let color = GameBoardView.colorToUIColor[myColor]!
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 56, height: 56), false, 0)
        color.setFill()
        UIRectFill(CGRect.zero.with(width: 56).with(height: 56))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(kCircleIconHeight: 56, showCloseButton: false))
        alert.addButton("OK", action: {})
        _ = alert.showCustom("Your color is \(GameBoardView.colorToString[myColor]!).", subTitle: "", color: .black, icon: image)
    }
    
    override func restartTapped() {
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
            let myColor = self.playerColors.first!
            let color = GameBoardView.colorToUIColor[myColor]!
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 56, height: 56), false, 0)
            color.setFill()
            UIRectFill(CGRect.zero.with(width: 56).with(height: 56))
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(kCircleIconHeight: 56, showCloseButton: false))
            alert.addButton("OK", action: {})
            _ = alert.showCustom("Your color is \(GameBoardView.colorToString[myColor]!).", subTitle: "", color: .black, icon: image)
            if self.playerColors.contains(self.game.currentPlayer.color) {
                self.allGR.forEach { $0.isEnabled = true }
            } else {
                self.allGR.forEach { $0.isEnabled = false }
                DispatchQueue.main.async {
                    let ai = self.aiCount < 2 ? self.twoPlayerAI() : self.multiplayerAI()
                    self.game.moveInDirection(ai.getNextMove())
                }
            }
            self.showHideActionBar()
        })
        alert.addButton("No", action: {})
        alert.showWarning("Confirm", subTitle: "Do you really want to restart?")
    }
    
    fileprivate func twoPlayerAI() -> GameAI {
        return GameAI(game: self.game.createCopy(), myColor: self.game.currentPlayer.color, wSelfLife: 553, wDiffLives: 8371, wSquareThreshold: 3, wSelfSpreadBelowThreshold: 5646, wSelfSpreadAboveThreshold: 3791, wOpponentSpread: 8583, wSelfInDanger: 6187, wOpponentInDangerBelowThreshold: 680, wOpponentInDangerAboveThreshold: 9157)
    }
    
    fileprivate func multiplayerAI() -> GameAI {
        return GameAI(game: self.game.createCopy(), myColor: self.game.currentPlayer.color, wSelfLife: 8420, wDiffLives: 9285, wSquareThreshold:0, wSelfSpreadBelowThreshold: 181, wSelfSpreadAboveThreshold: 4669, wOpponentSpread: 5890, wSelfInDanger: 4306, wOpponentInDangerBelowThreshold: 4200, wOpponentInDangerAboveThreshold: 7995)
    }
}

func randomFromArrayAndRemove<T>(_ a: inout [T]) -> T {
    let randomNumber = Int(arc4random_uniform(UInt32(a.count)))
    let item = a[randomNumber]
    a.remove(at: randomNumber)
    return item
}
