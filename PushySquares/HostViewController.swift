import UIKit
import FSPagerView
import SwiftyButton
import PushySquaresModel
import RxSwift
import RxCocoa
import MultipeerConnectivity

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

}