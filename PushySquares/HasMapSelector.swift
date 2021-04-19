import UIKit
import FSPagerView
import PushySquaresModel
import SCLAlertView
import StoreKit
import EZLoadingActivity

protocol HasMapSelector : SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var mapSelector: FSPagerView! { get }
    var mapSelectorPageControl: FSPageControl! { get }
    var maps: [Map] { get }
    var mapSelectorDelegate: MapSelectorDelegate { get }
    var productRequest: SKProductsRequest! { get set }
}

extension HasMapSelector {
    func setupMapSelector() {
        mapSelector.register(UINib(nibName: "GameBoardCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        mapSelector.transformer = FSPagerViewTransformer(type: .linear)
        mapSelectorPageControl.numberOfPages = maps.count
        mapSelectorPageControl.currentPage = mapSelector.currentIndex
        mapSelectorPageControl.setStrokeColor(.black, for: .normal)
        mapSelectorPageControl.setStrokeColor(.black, for: .selected)
        mapSelectorPageControl.setFillColor(.clear, for: .normal)
        mapSelectorPageControl.setFillColor(.black, for: .selected)
        mapSelector.delegate = mapSelectorDelegate
        mapSelector.dataSource = mapSelectorDelegate
    }

    var mapUnlocked: Bool {
        mapSelector.currentIndex <= 3 || UserDefaults.standard.bool(forKey: mapsUnlockedKey)
    }

    func updateMapSelectorItemSize() {
        let pageViewWidth = mapSelector.width
        let pageViewHeight = mapSelector.height
        let itemSideLength = min(pageViewWidth, pageViewHeight) * 0.7
        mapSelector.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
    }

    func promptUnlockMaps() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Unlock All Maps".localized) { [weak self] in
            self?.productRequest = SKProductsRequest(productIdentifiers: [unlockAllMapsProductID])
            self?.productRequest.delegate = self
            self?.productRequest.start()
            EZLoadingActivity.show("Loading...".localized, disableUI: true)
        }
        alert.addButton("Cancel".localized, action: {})
        alert.showInfo("This map is locked!".localized, subTitle: "Do you want to unlock all locked maps?".localized, circleIconImage: #imageLiteral(resourceName: "lockedicon"))
    }

}