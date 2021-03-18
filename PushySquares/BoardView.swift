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


    private func point(for position: Position) -> CGPoint {
        CGPoint(x: strokeWidth / 2 + position.x.f * squareLength, y: strokeWidth / 2 + position.y.f * squareLength)
    }

    private var squareLength: CGFloat {
        (BoardView.borderSize * self.width) / (BoardView.borderSize * board.boardState.columns.f + 1.0)
    }

    private var squareViewLength: CGFloat {
        squareLength - (squareLength / BoardView.borderSize)
    }

    private var strokeWidth: CGFloat {
        squareLength / BoardView.borderSize
    }

    private func squareViewPoint(for position: Position) -> CGPoint {
        let pointForPosition = point(for: position)
        let offset = squareLength / BoardView.borderSize / 2
        return CGPoint(x: pointForPosition.x + offset, y: pointForPosition.y + offset)
    }
}
