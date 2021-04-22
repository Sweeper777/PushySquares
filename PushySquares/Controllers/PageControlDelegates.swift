import UIKit
import FSPagerView
import PushySquaresModel

class PlayerCountSelectorDelegate: NSObject, FSPagerViewDelegate, FSPagerViewDataSource {
    let gameModes: [String]
    let pageControl: FSPageControl

    init(gameModes: [String], pageControl: FSPageControl) {
        self.gameModes = gameModes
        self.pageControl = pageControl
        super.init()
    }

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        gameModes.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = UIImage(named: gameModes[index])
        return cell
    }

    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }

    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        false
    }
}

class MapSelectorDelegate: NSObject, FSPagerViewDelegate, FSPagerViewDataSource {
    let maps: [Map]
    let pageControl: FSPageControl
    weak var owner: HasMapSelector?

    init(maps: [Map], pageControl: FSPageControl, owner: HasMapSelector) {
        self.maps = maps
        self.pageControl = pageControl
        self.owner = owner
        super.init()
    }

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        maps.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! GameBoardCell
        cell.board = maps[index]
        cell.locked = index > 3 && !UserDefaults.standard.bool(forKey: mapsUnlockedKey)
        return cell
    }

    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if index > 3 && !UserDefaults.standard.bool(forKey: mapsUnlockedKey) {
            owner?.promptUnlockMaps()
        }
    }
}