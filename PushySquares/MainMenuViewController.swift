import UIKit
import SwiftyButton
import PushySquaresModel

class MainMenuViewController : UIViewController {
    @IBOutlet var startButton: PressableButton!
    @IBOutlet var helpButton: PressableButton!
    @IBOutlet var joinButton: PressableButton!
    @IBOutlet var hostButton: PressableButton!

    override func viewDidLoad() {
        startButton.setTitle("START".localized, for: .normal)
        startButton.colors = PressableButton.ColorSet(
                button: UIColor.green.desaturated().darker(),
                shadow: UIColor.green.desaturated().darker().darker())
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        helpButton.setTitle("HELP".localized, for: .normal)
        helpButton.colors = PressableButton.ColorSet(
                button: UIColor.blue.desaturated(),
                shadow: UIColor.blue.desaturated().darker())
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)

        joinButton.setTitle("JOIN".localized, for: .normal)
        joinButton.colors = PressableButton.ColorSet(
                button: UIColor.yellow.darker().desaturated(),
                shadow: UIColor.yellow.darker().desaturated().darker())
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)

        hostButton.setTitle("HOST".localized, for: .normal)
        hostButton.colors = PressableButton.ColorSet(
                button: UIColor.red.desaturated(),
                shadow: UIColor.red.desaturated().darker())
        hostButton.addTarget(self, action: #selector(hostTapped), for: .touchUpInside)
    }

    @objc func startTapped() {
        guard let gameModeSelectorVC: GameModeSelectorViewController =
        UIStoryboard.main?.instantiateViewController(identifier: "GameModeSelectorVC") else {
            return
        }
        gameModeSelectorVC.isModalInPresentation = true
        gameModeSelectorVC.modalPresentationStyle = .formSheet
        gameModeSelectorVC.delegate = self
        present(gameModeSelectorVC, animated: true)
    }

    @objc func helpTapped() {

    }

    @objc func joinTapped() {
        guard let joinVC: JoinViewController =
        UIStoryboard.main?.instantiateViewController(identifier: "JoinVC") else {
            return
        }
        joinVC.isModalInPresentation = true
        joinVC.modalPresentationStyle = .formSheet
        joinVC.delegate = self
        present(joinVC, animated: true)
    }

    @objc func hostTapped() {
        guard let hostVC: HostViewController =
        UIStoryboard.main?.instantiateViewController(identifier: "HostVC") else {
            return
        }
        hostVC.isModalInPresentation = true
        hostVC.modalPresentationStyle = .formSheet
//        hostVC.delegate = self
        present(hostVC, animated: true)
    }
}

extension MainMenuViewController: GameModeSelectorDelegate {
    func didEndSelectingGameMode(playerCount: Int, aiCount: Int, map: Map) {
        guard let gameVC: GameViewController = UIStoryboard.main?.instantiateViewController(identifier: "GameVC") else {
            return
        }

        gameVC.map = map
        gameVC.playerCount = playerCount + aiCount

        if aiCount > 0 {
            let strategy = AIGameControllerStrategy(gameViewController: gameVC)
            strategy.hasHumanPlayer = playerCount > 0
            gameVC.strategy = strategy
        } else {
            gameVC.strategy = DefaultGameControllerStrategy()
        }

        gameVC.isModalInPresentation = true
        gameVC.modalPresentationStyle = .fullScreen

        presentedViewController?.dismiss(animated: true) { [weak self] in
            self?.present(gameVC, animated: true)
        }
    }
}