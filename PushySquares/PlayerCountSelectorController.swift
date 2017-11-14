import UIKit
import SwiftyButton
import GoogleMobileAds
import FSPagerView

class PlayerCountSelectorController: UIViewController {
    
    var interstitial: GADInterstitial!
    var pageView: FSPagerView!
    var pageControl: FSPageControl!
    var shouldShowAd = false
    
    let imageNames = ["2player", "3player", "4player", "playervsai"]
    var selectedImageIndex = 0
    
    func repositionViews() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
        
        let backButtonWeight: CGFloat
        if self.traitCollection.verticalSizeClass == .compact {
            backButtonWeight = 1.0 / 7.0
        } else {
            backButtonWeight = 1.0 / 12.0
        }
        let backButtonY = UIScreen.statusBarHeight + 8
        let backButtonX = 8.f
        let backButtonHeight = (view.height - 8) * backButtonWeight
        let backButtonWidth = 2 * backButtonHeight
        let backButton = PressableButton(frame: CGRect(x: backButtonX, y: backButtonY, width: backButtonWidth, height: backButtonHeight))
        let fontSize = fontSizeThatFits(size: backButton.frame.size, text: "BACK", font: UIFont(name: "Chalkboard SE", size: 0)!) * 0.7
        backButton.setAttributedTitle(
            NSAttributedString(string: "BACK", attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: fontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        backButton.colors = PressableButton.ColorSet(button: UIColor.gray, shadow: UIColor.gray.darker())
        backButton.shadowHeight = backButton.height * 0.1
        self.view.addSubview(backButton)
        
        let separator = backButton.height / 2
        let pageViewX = backButtonX
        let pageViewY = backButton.frame.maxY + separator
        let pageViewHeight = view.height - pageViewY - 8
        let pageViewWidth = view.width - pageViewX - 8
        pageView = FSPagerView(frame: CGRect(x: pageViewX, y: pageViewY, width: pageViewWidth, height: pageViewHeight * 0.9))
        self.view.addSubview(pageView)
        pageView.transformer = FSPagerViewTransformer(type: .linear)
        pageView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pageView.delegate = self
        pageView.dataSource = self
        let itemLength = min(pageViewWidth * 0.7, pageViewHeight)
        pageView.itemSize = CGSize(width: itemLength, height: itemLength)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            [weak self] in
            guard let `self` = self else { return }
            self.pageView.scrollToItem(at: self.selectedImageIndex, animated: false)
        }
        
        let pageControlHeight = min(pageViewHeight, pageViewWidth) / 10
        let pageControlY = pageView.frame.maxY
        pageControl = FSPageControl(frame: CGRect(x: pageViewX, y: pageControlY, width: pageViewWidth, height: pageControlHeight))
        pageControl.numberOfPages = imageNames.count
        pageControl.currentPage = pageView.currentIndex
        pageControl.setStrokeColor(.black, for: .normal)
        pageControl.setStrokeColor(.black, for: .selected)
        pageControl.setFillColor(.clear, for: .normal)
        pageControl.setFillColor(.black, for: .selected)
        self.view.addSubview(pageControl)
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        let longStartButton = (view.width - 24) / 2 >= backButton.width * 2
        let startButtonWidth = longStartButton ? backButton.width * 2 : backButtonWidth
        let startButtonX = view.width - 8 - startButtonWidth
        let startButtonText = longStartButton ? "START GAME" : "START"
        let startButton = PressableButton(frame: CGRect(x: startButtonX, y: backButtonY, width: startButtonWidth, height: backButtonHeight))
        let startFontSize = fontSizeThatFits(size: startButton.frame.size, text: startButtonText as NSString, font: UIFont(name: "Chalkboard SE", size: 0)!) * 0.7
        startButton.setAttributedTitle(
            NSAttributedString(string: startButtonText, attributes: [
                NSFontAttributeName: UIFont(name: "Chalkboard SE", size: startFontSize)!,
                NSForegroundColorAttributeName: UIColor.white
                ])
            , for: .normal)
        startButton.colors = PressableButton.ColorSet(button: UIColor.green.desaturated().darker(), shadow: UIColor.green.desaturated().darker().darker())
        startButton.shadowHeight = startButton.height * 0.1
        self.view.addSubview(startButton)
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        repositionViews()
    }
    
    override func viewDidLoad() {
        if arc4random_uniform(100) < 30 {
            shouldShowAd = true
            interstitial = GADInterstitial(adUnitID: adUnitID)
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            interstitial.delegate = self
            interstitial.load(request)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            [weak self] in
            self?.repositionViews()
        }
    }
    
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func start() {
        if pageView.currentIndex < 3 {
            performSegue(withIdentifier: "showGame", sender: pageView.currentIndex + 2)
        }
        if pageView.currentIndex == 3 {
            performSegue(withIdentifier: "showAIGame", sender: (1, 1))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AIGameViewController {
            let tuple = sender as! (Int, Int)
            vc.aiCount = tuple.1
            vc.playerCount = tuple.0
        } else if let vc = segue.destination as? GameViewController {
            vc.playerCount = sender as! Int
        }
    }
}

extension PlayerCountSelectorController: GADInterstitialDelegate {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        guard shouldShowAd else { return }
        ad.present(fromRootViewController: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shouldShowAd = false
    }
}

extension PlayerCountSelectorController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return imageNames.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = UIImage(named: imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFit
        cell.contentView.layer.shadowRadius = 0
        return cell
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
        selectedImageIndex = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return false
    }
}
