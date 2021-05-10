import UIKit
import FSPagerView
import SwiftyButton
import PushySquaresModel
import StoreKit
import GoogleMobileAds
import AppTrackingTransparency

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
    lazy var mapSelectorDelegate = MapSelectorDelegate(maps: maps, pageControl: mapSelectorPageControl, owner: self)
    lazy var inAppPurchaseManager = InAppPurchaseManager(owner: self)
    weak var delegate: GameModeSelectorDelegate?

    var shouldShowAd = false
    var hasAppeared = false
    var interstitial: GADInterstitialAd?

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

        view.bringSubviewToFront(startButton)
        view.bringSubviewToFront(backButton)

        if Int.random(in: 0..<100) < 30 {
            shouldShowAd = true
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { [weak self] status in
                    self?.loadAd()
                })
            } else {
                loadAd()
            }
        }
    }

    private func loadAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID,
                request: request,
                completionHandler: { [weak self] ad, error in
                    if let error = error {
                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                        return
                    }
                    self?.interstitial = ad
                    if (self?.shouldShowAd ?? false) && (self?.hasAppeared ?? false) {
                        self.map {
                            ad?.present(fromRootViewController: $0)
                        }
                    }
                })
    }

    @objc func startTapped() {
        if mapUnlocked {
            let (playerCount, aiCount) = gameModePlayerAICounts[playerCountSelector.currentIndex]
            let map = maps[mapSelector.currentIndex]
            delegate?.didEndSelectingGameMode(playerCount: playerCount, aiCount: aiCount, map: map)
        } else {
            promptUnlockMaps()
        }
    }


    @objc func backTapped() {
        dismiss(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasAppeared = true
        if shouldShowAd, let ad = interstitial {
            shouldShowAd = false
            ad.present(fromRootViewController: self)
        }
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shouldShowAd = false
    }
}

protocol GameModeSelectorDelegate: class {
    func didEndSelectingGameMode(playerCount: Int, aiCount: Int, map: Map)
}

let mapsUnlockedKey = "mapsUnlocked"