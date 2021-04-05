import UIKit
import FSPagerView
import SwiftyButton
import PushySquaresModel

class GameModeSelectorViewController: UIViewController, HasMapSelector {
    @IBOutlet var backButton: PressableButton!
    @IBOutlet var startButton: PressableButton!
    @IBOutlet var playerCountSelector: FSPagerView!
    @IBOutlet var mapSelector: FSPagerView!
    @IBOutlet var playerCountSelectorPageControl: FSPageControl!
    @IBOutlet var mapSelectorPageControl: FSPageControl!

    let gameModes = ["2player", "3player", "4player", "playervsai", "playervs3ai", "4ai"]
    let gameModePlayerAICounts: [(Int, Int)] = [
        (2, 0), (3, 0), (4, 0), (1, 1), (1, 3), (0, 4)
    ]

    let maps = allMaps.map {
        name -> Map in
        let url = Bundle.main.url(forResource: name, withExtension: "map")!
        return Map(file: url)
    }

    lazy var playerCountSelectorDelegate = PlayerCountSelectorDelegate(gameModes: gameModes, pageControl: playerCountSelectorPageControl)
    lazy var mapSelectorDelegate = MapSelectorDelegate(maps: maps, pageControl: mapSelectorPageControl)

    weak var delegate: GameModeSelectorDelegate?

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
        playerCountSelector.delegate = playerCountSelectorDelegate
        playerCountSelector.dataSource = playerCountSelectorDelegate

        setupMapSelector()
    }

    @objc func startTapped() {
        if mapUnlocked {
            let (playerCount, aiCount) = gameModePlayerAICounts[playerCountSelector.currentIndex]
            let map = maps[mapSelector.currentIndex]
            delegate?.didEndSelectingGameMode(playerCount: playerCount, aiCount: aiCount, map: map)
        } else {
            // TODO: show IAP prompt
        }
    }


    @objc func backTapped() {
        dismiss(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMapSelectorItemSize()
        playerCountSelector.itemSize = mapSelector.itemSize
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] context in
            self?.updateMapSelectorItemSize()
            self?.playerCountSelector.itemSize = self?.mapSelector.itemSize ?? .zero
        }
    }
}

protocol GameModeSelectorDelegate: class {
    func didEndSelectingGameMode(playerCount: Int, aiCount: Int, map: Map)
}

let mapsUnlockedKey = "mapsUnlocked"