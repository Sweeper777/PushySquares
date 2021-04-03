import UIKit
import FSPagerView
import SwiftyButton
import PushySquaresModel

class GameModeSelectorViewController: UIViewController {
    @IBOutlet var backButton: PressableButton!
    @IBOutlet var startButton: PressableButton!
    @IBOutlet var playerCountSelector: FSPagerView!
    @IBOutlet var mapSelector: FSPagerView!
    @IBOutlet var playerCountSelectorPageControl: FSPageControl!
    @IBOutlet var mapSelectorPageControl: FSPageControl!

    let gameModes = ["2player", "3player", "4player", "playervsai", "playervs3ai", "4ai"]
    let maps = allMaps.map {
        name -> Map in
        let url = Bundle.main.url(forResource: name, withExtension: "map")!
        return Map(file: url)
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

        playerCountSelector.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        playerCountSelector.transformer = FSPagerViewTransformer(type: .linear)
        playerCountSelectorPageControl.numberOfPages = gameModes.count
        playerCountSelectorPageControl.currentPage = playerCountSelector.currentIndex
        playerCountSelectorPageControl.setStrokeColor(.black, for: .normal)
        playerCountSelectorPageControl.setStrokeColor(.black, for: .selected)
        playerCountSelectorPageControl.setFillColor(.clear, for: .normal)
        playerCountSelectorPageControl.setFillColor(.black, for: .selected)

        mapSelector.register(UINib(nibName: "GameBoardCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        mapSelector.transformer = FSPagerViewTransformer(type: .linear)
        mapSelectorPageControl.numberOfPages = maps.count
        mapSelectorPageControl.currentPage = mapSelector.currentIndex
        mapSelectorPageControl.setStrokeColor(.black, for: .normal)
        mapSelectorPageControl.setStrokeColor(.black, for: .selected)
        mapSelectorPageControl.setFillColor(.clear, for: .normal)
        mapSelectorPageControl.setFillColor(.black, for: .selected)
    }

    @objc func startTapped() {

    }


    @objc func backTapped() {
        dismiss(animated: true)
    }
}
