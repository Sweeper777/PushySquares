import UIKit
import SwiftyUtils

@IBDesignable
class GameBoardView: UIView {
    static let colorToUIColor: [Color: UIColor] = [
        .color1: .red,
        .color2: .blue,
        .color3: .green,
        .color4: .yellow,
        .grey: .gray
    ]
    
    static let borderSize: CGFloat = 8
    
    weak var game: Game? {
        didSet {
            setNeedsDisplay()
        }
    }
    
}
