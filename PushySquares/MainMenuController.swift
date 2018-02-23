import UIKit
import SwiftyButton
import MultipeerConnectivity

class MainMenuController: UIViewController {
    @IBOutlet var logo: UIImageView!
    
    var viewsToBeRepositioned: [UIView] = []
    
    func repositionViews() {
        viewsToBeRepositioned.forEach { $0.removeFromSuperview() }
        viewsToBeRepositioned = []
        
        let startButtonY = 36 + logo.frame.maxY
        let startButtonWidth: CGFloat
        if traitCollection.horizontalSizeClass == .regular {
            startButtonWidth = view.width / 2
        } else {
            startButtonWidth = view.width * 0.8
        }
        let startButtonX = (view.width - startButtonWidth) / 2
        
        let startButton = PressableButton(frame:
            CGRect.zero
            .with(width: startButtonWidth)
            .with(x: startButtonX)
            .with(y: startButtonY)
            .with(height: view.height / 10))
        let fontSize = fontSizeThatFits(size: startButton.frame.size, text: "START".localized as NSString, font: UIFont(name: "Chalkboard SE", size: 0)!) * 0.7
        startButton.setAttributedTitle(
            NSAttributedString(string: "START".localized, attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: fontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        startButton.colors = PressableButton.ColorSet(button: UIColor.green.desaturated().darker(), shadow: UIColor.green.desaturated().darker().darker())
        startButton.shadowHeight = startButton.height * 0.1
        
        let helpButton = PressableButton(frame:
            startButton.frame
                .with(y: startButton.frame.maxY + startButton.height * 0.2))
        helpButton.setAttributedTitle(
            NSAttributedString(string: "HELP".localized, attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: fontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        helpButton.colors = PressableButton.ColorSet(button: UIColor.blue.desaturated(), shadow: UIColor.blue.desaturated().darker())
        helpButton.shadowHeight = helpButton.height * 0.1
        
        let hostButton = PressableButton(frame: helpButton.frame.with(y: helpButton.frame.maxY + helpButton.height * 0.2))
        hostButton.setAttributedTitle(
            NSAttributedString(string: "HOST".localized, attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: fontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        hostButton.colors = PressableButton.ColorSet(button: UIColor.red.desaturated(), shadow: UIColor.red.desaturated().darker())
        hostButton.shadowHeight = helpButton.height * 0.1
        
        let joinButton = PressableButton(frame: hostButton.frame.with(y: hostButton.frame.maxY + hostButton.height * 0.2))
        joinButton.setAttributedTitle(
            NSAttributedString(string: "JOIN".localized, attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: fontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        joinButton.colors = PressableButton.ColorSet(button: UIColor.yellow.darker().desaturated(), shadow: UIColor.yellow.darker().desaturated().darker())
        joinButton.shadowHeight = hostButton.height * 0.1
        
        viewsToBeRepositioned.append(startButton)
        viewsToBeRepositioned.append(helpButton)
        viewsToBeRepositioned.append(hostButton)
        viewsToBeRepositioned.append(joinButton)
        view.addSubview(startButton)
        view.addSubview(helpButton)
        view.addSubview(hostButton)
        view.addSubview(joinButton)
        
        startButton.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(helpPressed), for: .touchUpInside)
        hostButton.addTarget(self, action: #selector(hostPressed), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(joinPressed), for: .touchUpInside)
    }
    
    func startPressed() {
        guard !multipeerGameTransitioning else { return }
        performSegue(withIdentifier: "showPlayerCountSelector", sender: self)
    }
    
    func helpPressed() {
        guard !multipeerGameTransitioning else { return }
        performSegue(withIdentifier: "showHelp", sender: self)
    }
    
    func hostPressed() {
        guard !multipeerGameTransitioning else { return }
        performSegue(withIdentifier: "showHost", sender: self)
    }
    
    func joinPressed() {
        guard !multipeerGameTransitioning else { return }
        performSegue(withIdentifier: "showJoin", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        repositionViews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.repositionViews()
        }
    }
    
    var dataFromJoinVC: (MCSession, String?)!
    var dataFromHostVC: (MCSession, [MCPeerID: Color], String?)!
    
    @IBAction func unwindFromGame(segue: UIStoryboardSegue) {
        
    }
    
    var multipeerGameTransitioning = false
    @IBAction func unwindFromHost(segue: UIStoryboardSegue) {
        multipeerGameTransitioning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) { [weak self] in
            self?.multipeerGameTransitioning = false
            if let dataFromHost = self?.dataFromHostVC {
                self?.performSegue(withIdentifier: "showMultipeerGame", sender: dataFromHost)
            }
        }
    }
    
    @IBAction func unwindFromJoin(segue: UIStoryboardSegue) {
        multipeerGameTransitioning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) { [weak self] in
            self?.multipeerGameTransitioning = false
            if let dataFromJoin = self?.dataFromJoinVC {
                self?.performSegue(withIdentifier: "showMultipeerGame", sender: dataFromJoin)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MultipeerGameViewController else { return }
        
        if let data = sender as? (MCSession, String?) {
            vc.session = data.0
            vc.playerCount = data.0.connectedPeers.count + 1
            data.0.delegate = vc
            if let map = data.1 {
                vc.map = Map(file: Bundle.main.path(forResource: map, ofType: "map")!)
            }
        } else if let sessionTuple = sender as? (MCSession, [MCPeerID: Color], String?) {
            vc.session = sessionTuple.0
            vc.playerColorsDict = sessionTuple.1
            vc.playerCount = sessionTuple.0.connectedPeers.count + 1
            sessionTuple.0.delegate = vc
            if let map = sessionTuple.2 {
                vc.map = Map(file: Bundle.main.path(forResource: map, ofType: "map")!)
            }
        }
    }
}
