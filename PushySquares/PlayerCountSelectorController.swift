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
            [weak self] in
        }
        
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameViewController {
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
