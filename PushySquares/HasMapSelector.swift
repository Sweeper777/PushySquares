import UIKit
import FSPagerView
import PushySquaresModel

protocol HasMapSelector {
    var mapSelector: FSPagerView! { get }
    var mapSelectorPageControl: FSPageControl! { get }
    var maps: [Map] { get }
    var mapSelectorDelegate: MapSelectorDelegate { get }
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
}