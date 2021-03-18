import UIKit
import PushySquaresModel
import SwiftyUtils

class BoardView : UIView {
    static let colorToUIColor: [Color: UIColor] = [
        .red: .red,
        .blue: .blue,
        .green: .green,
        .yellow: .yellow,
    ]

    static let borderSize: CGFloat = 8

    var board: BoardProvider! {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }

}
