import UIKit
import FSPagerView
import SwiftyButton

class GameModeSelectorViewController: UIViewController {
    @IBOutlet var backButton: PressableButton!
    @IBOutlet var startButton: PressableButton!
    @IBOutlet var playerCountSelector: FSPagerView!
    @IBOutlet var mapSelector: FSPagerView!
    @IBOutlet var playerCountSelectorPageControl: FSPageControl!
    @IBOutlet var mapSelectorPageControl: FSPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        startButton.setTitle("START".localized, for: .normal)
        startButton.colors = PressableButton.ColorSet(
                button: UIColor.green.desaturated().darker(),
                shadow: UIColor.green.desaturated().darker().darker())
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        backButton.setTitle("BACK".localized, for: .normal)
        backButton.colors = PressableButton.ColorSet(
                button: UIColor.green.desaturated().darker(),
                shadow: UIColor.green.desaturated().darker().darker())
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    @objc func startTapped() {

    }


    @objc func backTapped() {

    }
}
