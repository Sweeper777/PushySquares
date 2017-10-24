import UIKit
import SCLAlertView
import SwiftyButton
import MultipeerConnectivity

class MultipeerGameViewController: GameViewController {
    var session: MCSession!
    var playerColorsDict: [MCPeerID: Color]!
    var disconnectHandled = false
    
    var myColor: Color! {
        didSet {
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
    }
    
    override func swipedUp() {
        try? session.send(Data(bytes: [DataCodes.moveUp.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        super.swipedUp()
    }
    
    override func swipedDown() {
        try? session.send(Data(bytes: [DataCodes.moveDown.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        super.swipedDown()
    }
    
    override func swipedLeft() {
        try? session.send(Data(bytes: [DataCodes.moveLeft.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        super.swipedLeft()
    }
    
    override func swipedRight() {
        try? session.send(Data(bytes: [DataCodes.moveRight.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        super.swipedRight()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if playerColorsDict == nil {
            try? session.send(Data(bytes: [DataCodes.ready.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        } else {
            myColor = playerColorsDict[session.myPeerID]!
        }
        if game.currentPlayer.color != myColor {
            allGR.forEach { $0.isEnabled = false }
        }
    }
    
    override func animationDidComplete() {
        if game.currentPlayer.color != myColor {
            allGR.forEach { $0.isEnabled = false }
        }
    }
    
    override func showHideActionBar() {
        
        if let quitButton = self.view.viewWithTag(1) {
            UIView.animate(withDuration: 0.25, animations: {
                quitButton.alpha = 0
            }, completion: {
                if $0 {
                    quitButton.removeFromSuperview()
                }
            })
        } else {
            let actionBarButtonLength = min(self.view.width, self.view.height) / 8
            let actionBarYWeight = 0.7.f
            let actionBarY = self.view.height * actionBarYWeight
            let actionBarX = (self.view.width - actionBarButtonLength) / 2
            let quitButton = PressableButton()
            quitButton.frame = CGRect(x: actionBarX, y: actionBarY, width: actionBarButtonLength, height: actionBarButtonLength)
            quitButton.shadowHeight = quitButton.height * 0.1
            quitButton.colors = PressableButton.ColorSet(button: UIColor.gray.desaturated(), shadow: UIColor.gray.desaturated().darker())
            
            let fontSize = fontSizeThatFits(size: quitButton.frame.size, text: "↺", font: UIFont.systemFont(ofSize: 0))
            quitButton.setAttributedTitle(
                NSAttributedString.init(string: "×", attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
                    NSForegroundColorAttributeName: UIColor.white
                    ]), for: .normal)
            
            quitButton.alpha = 0
            quitButton.tag = 1
            quitButton.addTarget(self, action: #selector(quitTapped), for: .touchUpInside)
            self.view.addSubview(quitButton)
            UIView.animate(withDuration: 0.25, animations: {
                quitButton.alpha = 1
            })
        }
    }
    
    override func quitTapped() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Yes", action: {
            [weak self] in
            guard let `self` = self else { return }
            self.disconnectHandled = true
            self.session.disconnect()
            self.performSegue(withIdentifier: "quitGame", sender: self)
        })
        alert.addButton("No", action: {})
        alert.showWarning("Cofirm", subTitle: "Do you really want to quit?")
    }
}
}
