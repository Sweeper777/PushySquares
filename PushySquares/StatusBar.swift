import UIKit
import FittableFontLabel
import SwiftyUtils
import PushySquaresModel

@IBDesignable
class StatusBar: UIView {
    @IBOutlet var imgNewSquareIn: UIImageView!
    @IBOutlet var imgCurrentTurn: SquareView!
    @IBOutlet var imgLives: UIImageView!

    @IBOutlet var currentTurnHeader: UILabel!

    private var centerAlignedParaStyle: NSParagraphStyle = {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        return paraStyle
    }()

    private func viewFromNibForClass() -> UIView {

        let bundle = Bundle(for: StatusBar.self)
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

        return view
    }

    private func imageFrom(_ str: NSAttributedString) -> UIImage {
        let size = str.size()
        UIGraphicsBeginImageContext(size)
        str.draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
