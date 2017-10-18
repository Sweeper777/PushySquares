import UIKit
import MultipeerConnectivity
import SwiftyButton
import RxSwift
import RxCocoa
import SCLAlertView

enum ConnectionState {
    case connecting
    case connected
    case notConnected
    case error
}

struct PeerIDStateTuple : Equatable {
    let peerID: MCPeerID
    var state: ConnectionState
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
        self.state = .notConnected
    }
    
    static func ==(lhs: PeerIDStateTuple, rhs: PeerIDStateTuple) -> Bool {
        return lhs.peerID == rhs.peerID
    }
}

class HostViewController: UIViewController {
    var foundPeers = Variable([PeerIDStateTuple]())
    let disposeBag = DisposeBag()
    
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    var session: MCSession!
    var browser: MCNearbyServiceBrowser!
    
    func repositionViews() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
        
    }
    
    override func viewDidLoad() {
        session = MCSession(peer: peerID)
        session.delegate = self
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "pushysquares\(Bundle.main.appBuild)")
        browser.delegate = self
        browser.startBrowsingForPeers()
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
}
