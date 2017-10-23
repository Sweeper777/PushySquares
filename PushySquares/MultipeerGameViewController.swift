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
}
