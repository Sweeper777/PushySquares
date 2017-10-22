import UIKit
import SwiftyButton
import MultipeerConnectivity

class JoinViewController : UIViewController {
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var connectedPeerID: MCPeerID? {
        didSet {
            if let connectedPeer = connectedPeerID {
                activityIndicator.stopAnimating()
                connectionStatusLabel.text = "Connected to \(connectedPeer.displayName)"
            } else {
                activityIndicator.startAnimating()
                connectionStatusLabel.text = "Waiting to be connected to a game..."
            }
        }
    }
    
    var connectionStatusLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    
    func repositionViews() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
        
        let backButtonWeight: CGFloat
        if self.traitCollection.verticalSizeClass == .compact {
            backButtonWeight = 1.0 / 7.0
        } else {
            backButtonWeight = 1.0 / 12.0
        }
        let backButtonY = UIScreen.statusBarHeight + 8
        let backButtonX = 8.f
        let backButtonHeight = (view.height - 8) * backButtonWeight
        let backButtonWidth = 2.5 * backButtonHeight
        let backButton = PressableButton(frame: CGRect(x: backButtonX, y: backButtonY, width: backButtonWidth, height: backButtonHeight))
        let fontSize = fontSizeThatFits(size: backButton.frame.size, text: "BACK", font: UIFont(name: "Chalkboard SE", size: 0)!) * 0.7
        backButton.setAttributedTitle(
            NSAttributedString(string: "BACK", attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: fontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        backButton.colors = PressableButton.ColorSet(button: UIColor.gray, shadow: UIColor.gray.darker())
        backButton.shadowHeight = backButton.height * 0.1
        self.view.addSubview(backButton)
        
        let activityIndicatorLength = min(view.width, view.height) / 5
        let activityIndicatorCenterX = view.width / 2
        let activityIndicatorCenterY = view.height / 2
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = CGPoint(x: activityIndicatorCenterX, y: activityIndicatorCenterY)
        view.addSubview(activityIndicator)
        
    }
    
}
