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
        
        let backButtonWeight: CGFloat
        if self.traitCollection.verticalSizeClass == .compact {
            backButtonWeight = 1.0 / 7.0
        } else {
            backButtonWeight = 1.0 / 12.0
        }
        let backButtonY = UIScreen.statusBarHeight + 8
        let backButtonX = 8.f
        let backButtonHeight = (view.height - 8) * backButtonWeight
        let backButtonWidth = min(2 * backButtonHeight, (view.width - 24) / 3 )
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
        
        let separator = backButton.height / 2
        
        let hintLabel = UILabel(frame: CGRect(
            x: backButton.x,
            y: backButton.frame.maxY + separator,
            width: view.width - backButton.x - 8,
            height: backButton.height * 2))
        hintLabel.text = "Nearby devices that are willing to join a game is shown below. Tap on a device to connect it to the game."
        hintLabel.numberOfLines = 0
        hintLabel.font = UIFont(name: "Chalkboard SE", size: hintLabel.font.pointSize)
        view.addSubview(hintLabel)
        
        let tableViewX = backButtonX
        let tableViewY = hintLabel.frame.maxY
        let tableViewHeight = view.height - tableViewY - 8
        let tableViewWidth = view.width - tableViewX - 8
        let tableView = UITableView(frame: CGRect(x: tableViewX, y: tableViewY, width: tableViewWidth, height: tableViewHeight))
        tableView.register(UINib(nibName: "PeerTableViewCell", bundle: nil) , forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        foundPeers.asObservable().bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            row, model, cell in
            cell.backgroundColor = .clear
            cell.textLabel!.text = model.peerID.displayName
            cell.textLabel!.font = UIFont(name: "Chalkboard SE", size: cell.textLabel!.font.pointSize)
            cell.detailTextLabel!.font = UIFont(name: "Chalkboard SE", size: cell.detailTextLabel!.font.pointSize)
            switch model.state {
            case .connected:
                cell.detailTextLabel!.text = "Connected"
            case .connecting:
                cell.detailTextLabel!.text = "Connecting..."
            case .error:
                cell.detailTextLabel!.text = "Unable to connect"
            case .notConnected:
                cell.detailTextLabel!.text = ""
            }
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(PeerIDStateTuple.self).bind { [weak self] (model) in
            guard let `self` = self else { return }
            tableView.deselectRow(at: IndexPath(row: self.foundPeers.value.index(of: model)!, section: 0), animated: false)
            guard let index = self.foundPeers.value.index(where: { $0.peerID == model.peerID }) else { return }
            if self.foundPeers.value[index].state == .error || self.foundPeers.value[index].state == .notConnected {
                if self.foundPeers.value.filter({ $0.state == .connected || $0.state == .connecting }).count == 3 {
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    alert.addButton("OK", action: {})
                    alert.showError("Too many players!", subTitle: "You can only connect at most 3 players to the game.")
                    return
                }
                self.browser.invitePeer(self.foundPeers.value[index].peerID, to: self.session, withContext: nil, timeout: 10)
                self.foundPeers.value[index].state = .connecting
            } else {
                try? self.session.send(Data(bytes: [DataCodes.quit.rawValue]), toPeers: [self.foundPeers.value[index].peerID], with: .reliable)
            }
            }.disposed(by: disposeBag)
        
        view.addSubview(tableView)
        
        let longStartButton = (view.width - 24) / 2 >= backButton.width * 2
        let startButtonWidth = longStartButton ? backButton.width * 2 : backButtonWidth
        let startButtonX = view.width - 8 - startButtonWidth
        let startButtonText = longStartButton ? "START GAME" : "START"
        let startButton = PressableButton(frame: CGRect(x: startButtonX, y: backButtonY, width: startButtonWidth, height: backButtonHeight))
        let startFontSize = fontSizeThatFits(size: startButton.frame.size, text: startButtonText as NSString, font: UIFont(name: "Chalkboard SE", size: 0)!) * 0.7
        startButton.setAttributedTitle(
            NSAttributedString(string: startButtonText, attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: startFontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        startButton.colors = PressableButton.ColorSet(button: UIColor.green.desaturated().darker(), shadow: UIColor.green.desaturated().darker().darker())
        startButton.shadowHeight = startButton.height * 0.1
        startButton.alpha = 0
        view.addSubview(startButton)
        
        let mapNuttonX = backButton.frame.maxX + 8
        let mapButton = PressableButton(frame: CGRect(x: mapNuttonX, y: backButtonY, width: backButtonWidth, height: backButtonHeight))
        mapButton.setAttributedTitle(
            NSAttributedString(string: "MAPS", attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: fontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        mapButton.colors = PressableButton.ColorSet(button: UIColor.blue.desaturated(), shadow: UIColor.blue.desaturated().darker())
        mapButton.shadowHeight = mapButton.height * 0.1
        self.view.addSubview(mapButton)
        
        foundPeers.asObservable().map{
            peers -> CGFloat in
            if peers.contains(where: {$0.state == .connecting}) {
                return 0
            }
            if peers.filter({ $0.state == .connected}).count == 0 {
                return 0
            }
            return 1
        }.bind(to: startButton.rx.alpha).disposed(by: disposeBag)
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        mapButton.addTarget(self, action: #selector(selectMap), for: .touchUpInside)
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
    
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func start() {
        var peerToColorDict = [peerID: Color.color1, session.connectedPeers[0]: Color.color3]
        if session.connectedPeers.count > 1 {
            peerToColorDict[session.connectedPeers[1]] = .color2
        }
        
        if session.connectedPeers.count > 2 {
            peerToColorDict[session.connectedPeers[2]] = .color4
        }
        try? session.send(Data(bytes: [DataCodes.startGame.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        performSegue(withIdentifier: "unwindToMainMenu", sender: (session, peerToColorDict))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MainMenuController else { return }
        
        if let sessionTuple = sender as? (MCSession, [MCPeerID: Color]) {
            vc.sessionDictTuple = sessionTuple
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
        if let index = foundPeers.value.index(where: { $0.peerID == peerID }) {
            switch state {
            case .connected:
                foundPeers.value[index].state = .connected
            case .connecting:
                foundPeers.value[index].state = .connecting
            case .notConnected:
                if foundPeers.value[index].state == .connected {
                    foundPeers.value[index].state = .notConnected
                } else {
                    foundPeers.value[index].state = .error
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let peerIDStateTuple = PeerIDStateTuple(peerID: peerID)
        if foundPeers.value.contains(peerIDStateTuple) {
            _ = foundPeers.value.remove(object: peerIDStateTuple)
        }
        foundPeers.value.append(peerIDStateTuple)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let peerIDStateTuple = PeerIDStateTuple(peerID: peerID)
         _ = foundPeers.value.remove(object: peerIDStateTuple)
    }
}
