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
    
}
