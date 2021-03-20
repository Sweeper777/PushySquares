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


    private func imageFrom(_ str: NSAttributedString) -> UIImage {
        let size = str.size()
        UIGraphicsBeginImageContext(size)
        str.draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
