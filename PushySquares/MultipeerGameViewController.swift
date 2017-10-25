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

extension MultipeerGameViewController: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if data.count > 1 && playerColorsDict == nil {
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [MCPeerID: Int] {
                self.playerColorsDict = dict.map { ($0, Color(rawValue: $1)!) }
                DispatchQueue.main.async {
                    [weak self] in
                    guard let `self` = self else { return }
                    self.myColor = self.playerColorsDict[self.session.myPeerID]
                }
            }
            return
        }
        
        if data[0] == DataCodes.ready.rawValue && playerColorsDict != nil {
            let dictToSend = playerColorsDict.map { ($0, $1.rawValue) }
            print(dictToSend)
            let data = NSKeyedArchiver.archivedData(withRootObject: dictToSend)
            try? session.send(data, toPeers: [peerID], with: .reliable)
        }
        
        if data[0] == DataCodes.moveUp.rawValue {
            DispatchQueue.main.async { [weak self] in
                self?.game.moveUp()
            }
        }
        
        if data[0] == DataCodes.moveDown.rawValue {
            DispatchQueue.main.async { [weak self] in
                self?.game.moveDown()
            }
        }
        
        if data[0] == DataCodes.moveLeft.rawValue {
            DispatchQueue.main.async { [weak self] in
                self?.game.moveLeft()
            }
        }
        
        if data[0] == DataCodes.moveRight.rawValue {
            DispatchQueue.main.async { [weak self] in
                self?.game.moveRight()
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard state == .notConnected else { return }
        
        if game.players.filter({ $0.lives > 0 }).count < 2 {
            return
        }
        
        if session.connectedPeers.isEmpty && !disconnectHandled {
            disconnectHandled = true
            if game.players.filter({ $0.lives > 0 }).count > 2 {
                DispatchQueue.main.async { [weak self] in
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    alert.addButton("OK", action: {
                        [weak self] in
                        self?.dismiss(animated: true, completion: nil)
                    })
                    _ = alert.showWarning("Oops!", subTitle: "You disconnected from the game.")
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    alert.addButton("OK", action: {
                        [weak self] in
                        self?.dismiss(animated: true, completion: nil)
                    })
                    _ = alert.showWarning("Game Over", subTitle: "All other players disconnected.")
                }
            }
        }
        
        if !session.connectedPeers.isEmpty {
            DispatchQueue.main.async {
                [weak self] in
                self?.handleDisconnection(of: peerID)
            }
            
        }
    }
    
    func handleDisconnection(of peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
}
