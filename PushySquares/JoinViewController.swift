import UIKit
import SwiftyButton
import MultipeerConnectivity
import PushySquaresModel

class JoinViewController: UIViewController {

    @IBOutlet var backButton: PressableButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var checkmark: UIImageView!
    @IBOutlet var hintLabel: UILabel!

    let peerID = MCPeerID(displayName: UIDevice.current.name)
    lazy var advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "pushysquares\(Bundle.main.appBuild)")
    lazy var session = MCSession(peer: peerID)
    var connectedPeerID: MCPeerID? {
        didSet {
            if let connectedPeer = connectedPeerID {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                checkmark.isHidden = false
                hintLabel.text = String(format: "Connected to %@".localized, connectedPeer.displayName)
            } else {
                activityIndicator.isHidden = false
                checkmark.isHidden = true
                activityIndicator.startAnimating()
                hintLabel.text = "Waiting to be connected to a game...".localized
            }
        }
    }


    override func viewDidLoad() {
        backButton.setTitle("BACK".localized, for: .normal)
        backButton.colors = PressableButton.ColorSet(
                button: UIColor.gray,
                shadow: UIColor.gray.darker())
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        connectedPeerID = nil
        advertiser.startAdvertisingPeer()
    }

    @objc func backTapped() {

    }
}

protocol JoinViewControllerDelegate: class {
    func gameWillStart(session: MCSession, map: String)
}