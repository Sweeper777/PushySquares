import UIKit
import FSPagerView
import SwiftyButton
import PushySquaresModel
import RxSwift
import RxCocoa
import MultipeerConnectivity
import SCLAlertView

class HostViewController: UIViewController, HasMapSelector {
    @IBOutlet var backButton: PressableButton!
    @IBOutlet var startButton: PressableButton!
    @IBOutlet var mapSelector: FSPagerView!
    @IBOutlet var mapSelectorPageControl: FSPageControl!
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    let maps = allMaps.map {
        name -> Map in
        let url = Bundle.main.url(forResource: name, withExtension: "map")!
        return Map(file: url)
    }
    lazy var mapSelectorDelegate = MapSelectorDelegate(maps: maps, pageControl: mapSelectorPageControl)

    var foundPeers = BehaviorRelay<[PeerIDStateTuple]>(value: [])
    let disposeBag = DisposeBag()

    let peerID = MCPeerID(displayName: UIDevice.current.name)
    lazy var browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "pushysquares\(Bundle.main.appBuild)")
    lazy var session = MCSession(peer: peerID)

    var isConnected: Bool {
        session.connectedPeers.isNotEmpty
    }

    var connectedPlayersCount: Int {
        foundPeers.value.filter({ $0.state == .connected || $0.state == .connecting }).count
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        startButton.setTitle("START".localized, for: .normal)
        startButton.colors = PressableButton.ColorSet(
                button: UIColor.green.desaturated().darker(),
                shadow: UIColor.green.desaturated().darker().darker())
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        backButton.setTitle("BACK".localized, for: .normal)
        backButton.colors = PressableButton.ColorSet(
                button: UIColor.gray,
                shadow: UIColor.gray.darker())
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        hintLabel.text = "Nearby devices that are willing to join a game is shown below. Tap on a device to connect it to the game.".localized

        setupMapSelector()

        foundPeers.asObservable().bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            row, model, cell in
            cell.backgroundColor = .clear
            cell.textLabel!.text = model.peerID.displayName
//            cell.textLabel!.font = UIFont(name: "Chalkboard SE", size: cell.textLabel!.font.pointSize)
//            cell.detailTextLabel!.font = UIFont(name: "Chalkboard SE", size: cell.detailTextLabel!.font.pointSize)
            switch model.state {
            case .connected:
                cell.detailTextLabel!.text = "Connected".localized
            case .connecting:
                cell.detailTextLabel!.text = "Connecting...".localized
            case .error:
                cell.detailTextLabel!.text = "Unable to connect".localized
            case .notConnected:
                cell.detailTextLabel!.text = ""
            }
        }.disposed(by: disposeBag)

        browser.delegate = self
        session.delegate = self
    }

    @objc func startTapped() {

    }

    @objc func backTapped() {
        if isConnected {
            try? session.send(Data([DataCodes.quit.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        }
        session.disconnect()
        dismiss(animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMapSelectorItemSize()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] context in
            self?.updateMapSelectorItemSize()
        }
    }
}

extension HostViewController: MCSessionDelegate, MCNearbyServiceBrowserDelegate {
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if let index = foundPeers.value.firstIndex(where: { $0.peerID == peerID }) {
            foundPeers.acceptByMutating {
                switch state {
                case .connected:
                    $0[index].state = .connected
                case .connecting:
                    $0[index].state = .connecting
                case .notConnected:
                    if $0[index].state == .connected {
                        $0[index].state = .notConnected
                    } else {
                        $0[index].state = .error
                    }
                @unknown default:
                    return
                }
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let peerIDStateTuple = PeerIDStateTuple(peerID: peerID)
        foundPeers.acceptByMutating {
            if $0.contains(peerIDStateTuple) {
                $0.removeAll(where: { $0 == peerIDStateTuple })
            }
            $0.append(peerIDStateTuple)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let peerIDStateTuple = PeerIDStateTuple(peerID: peerID)
        foundPeers.acceptByMutating {
            $0.removeAll(where: { $0 == peerIDStateTuple })
        }
    }
}

extension BehaviorRelay {
    func acceptByMutating(_ block: (inout Element) -> Void) {
        var copy = value
        block(&copy)
        accept(copy)
    }
}