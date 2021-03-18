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

    private func drawSimpleStripes(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {

        let stripeWidth: CGFloat = strokeWidth
        let m = stripeWidth / 2.0

        guard let c = UIGraphicsGetCurrentContext() else { return }
        c.setLineWidth(stripeWidth)

        let r = CGRect(x: x, y: y, width: width, height: height)
        let longerSide = width > height ? width : height

        c.saveGState()
        c.clip(to: r)

        var p = x - longerSide
        while p <= x + width {

            c.setStrokeColor(UIColor(hex: "ccc3a9").cgColor)
            c.move( to: CGPoint(x: p-m, y: y-m) )
            c.addLine( to: CGPoint(x: p+m+height, y: y+m+height) )
            c.strokePath()

            p += stripeWidth

            c.setStrokeColor(UIColor.clear.cgColor)
            c.move( to: CGPoint(x: p-m, y: y-m) )
            c.addLine( to: CGPoint(x: p+m+height, y: y+m+height) )
            c.strokePath()

            p += stripeWidth
        }

        c.restoreGState()
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
