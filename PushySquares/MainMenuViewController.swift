import UIKit
import SwiftyButton


class MainMenuViewController : UIViewController {
    @IBOutlet var startButton: PressableButton!
    @IBOutlet var helpButton: PressableButton!
    @IBOutlet var joinButton: PressableButton!
    @IBOutlet var hostButton: PressableButton!

    override func viewDidLoad() {
        startButton.setTitle("PLAY".localized, for: .normal)
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
        performSegue(withIdentifier: "showGameModeSelector", sender: nil)
    }

    @objc func helpTapped() {

    }

    @objc func joinTapped() {

    }

    @objc func hostTapped() {

    }
}
