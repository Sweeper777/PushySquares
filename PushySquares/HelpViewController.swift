import UIKit
import WebKit
import SwiftyButton
import SCLAlertView

class HelpViewController : UIViewController {
    @IBOutlet var backButton: PressableButton!
    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        backButton.setTitle("BACK".localized, for: .normal)
        backButton.colors = PressableButton.ColorSet(
                button: UIColor.gray,
                shadow: UIColor.gray.darker())
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)


    private func showErrorMessage(_ message: String) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("OK".localized, action: {})
        // TODO: localise this!
        alert.showError("Error".localized, subTitle: message)
    }

    @objc func backTapped() {
        dismiss(animated: true)
    }
}
