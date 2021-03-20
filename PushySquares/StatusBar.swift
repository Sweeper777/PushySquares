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

}
