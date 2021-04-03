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

