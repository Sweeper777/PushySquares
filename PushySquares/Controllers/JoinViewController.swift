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
    lazy var session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
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

    weak var delegate: MultipeerViewControllerDelegate?

    override func viewDidLoad() {
        backButton.setTitle("BACK".localized, for: .normal)
        backButton.colors = PressableButton.ColorSet(
                button: UIColor.gray,
                shadow: UIColor.gray.darker())
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        connectedPeerID = nil
        session.delegate = self
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }

    @objc func backTapped() {
        session.disconnect()
        dismiss(animated: true)
    }

    deinit {
        advertiser.stopAdvertisingPeer()
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
                DispatchQueue.main.async { [weak self] in
                    self?.connectedPeerID = nil
                }
            }
        default: break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if data[0] == DataCodes.quit.rawValue {
            session.disconnect()
            DispatchQueue.main.async { [weak self] in
                self?.connectedPeerID = nil
            }
        }
        if data[0] == DataCodes.startGame.rawValue {
            let startInfoData = Data(data.dropFirst())
            let startInfo = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(startInfoData) as! StartInfo
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.gameWillStart(session: session, startInfo: startInfo)
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

protocol MultipeerViewControllerDelegate: class {
    func gameWillStart(session: MCSession, startInfo: StartInfo)
}