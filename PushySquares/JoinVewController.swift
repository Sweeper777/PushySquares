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
                connectionStatusLabel.text = String(format: "Connected to %@".localized, connectedPeer.displayName)
            } else {
                activityIndicator.startAnimating()
                connectionStatusLabel.text = "Waiting to be connected to a game...".localized
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
        let fontSize = fontSizeThatFits(size: backButton.frame.size, text: "BACK".localized as NSString, font: UIFont(name: "Chalkboard SE", size: 0)!) * 0.7
        backButton.setAttributedTitle(
            NSAttributedString(string: "BACK".localized, attributes: [
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
        
        let labelX = 0.f
        let labelY = activityIndicator.frame.maxY + 8
        let labelWidth = view.width
        let labelHeight = activityIndicatorLength
        connectionStatusLabel = UILabel(frame: CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight))
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.font = UIFont(name: "Chalkboard SE", size: connectionStatusLabel.font.pointSize)
        view.addSubview(connectionStatusLabel)
        if let connectedPeer = connectedPeerID {
            activityIndicator.stopAnimating()
            connectionStatusLabel.text = String(format: "Connected to %@".localized, connectedPeer.displayName)
        } else {
            activityIndicator.startAnimating()
            connectionStatusLabel.text = "Waiting to be connected to a game...".localized
        }
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        session = MCSession(peer: peerID)
        session.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "pushysquares\(Bundle.main.appBuild)")
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        repositionViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        repositionViews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            [weak self] in
            self?.repositionViews()
        }
    }
    
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MainMenuController else { return }
        
        if let data = sender as? (MCSession, String?) {
            vc.dataFromJoinVC = data
        }
    }
}

extension JoinViewController : MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            if connectedPeerID == peerID {
                connectedPeerID = nil
            }
        default: break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if data[0] == DataCodes.quit.rawValue {
            session.disconnect()
            connectedPeerID = nil
        }
        if data[0] == DataCodes.startGame.rawValue {
            var map: String?
            if data.count == 3 && data[1] == DataCodes.mapInfo.rawValue {
                map = allMaps[Int(data[2])]
            }
            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: "unwindToMainMenu", sender: (session, map))
            }
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if connectedPeerID != nil {
            invitationHandler(false, nil)
        } else {
            invitationHandler(true, session)
            connectedPeerID = peerID
        }
    }
}
