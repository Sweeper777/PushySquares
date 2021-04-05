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

}