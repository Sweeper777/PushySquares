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
    
    private var squareLength: CGFloat {
        return (GameBoardView.borderSize * self.width) / (GameBoardView.borderSize * game!.board.columns.f + 1.0)
    }
    
    private var squareViewLength: CGFloat {
        return squareLength - (squareLength / GameBoardView.borderSize)
    }
    
    private var strokeWidth: CGFloat {
        return squareLength / GameBoardView.borderSize
    }
    
    private func squareViewPoint(for position: Position) -> CGPoint {
        let pointForPosition = point(for: position)
        let offset = squareLength / GameBoardView.borderSize / 2
        return CGPoint(x: pointForPosition.x + offset, y: pointForPosition.y + offset)
    }
    
    func position(forViewTag tag: Int) -> Position {
        return Position(tag / 1000, tag % 1000)
    }
}
