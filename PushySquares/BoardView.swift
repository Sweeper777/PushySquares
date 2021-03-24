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

    private let animationManager = AnimationManager<ViewAnimationPhase>()

    override func draw(_ rect: CGRect) {
        guard let board = board else {
            return
        }

        let squareSize = CGSize(width: squareViewLength, height: squareViewLength)
        let wallSquare = SquareView(frame: CGRect(origin: .zero, size: squareSize))
        wallSquare.backgroundColor = .white
        var spawnPoints = [Position: Color]()
        for x in 0..<board.map.columns {
            for y in 0..<board.map.rows {
                let squareViewPos = squareViewPoint(for: Position(x, y))
                let squarePos = point(for: Position(x, y))
                switch board.map[x, y] {
                case .void:
                    break
                case .spawnpoint(let color):
                    spawnPoints[Position(x, y)] = color
                case .ground:
                    drawBorder(point: squarePos, color: .black)
                    drawSimpleStripes(x: squareViewPos.x, y: squareViewPos.y, width: squareViewLength, height: squareViewLength)
                case .slippery:
                    UIImage(named: "wet")!.draw(in: CGRect(origin: squarePos, size: squareSize))
                case .wall:
                    drawBorder(point: squarePos, color: .black)
                    drawWall(point: squareViewPos, wallSquare: wallSquare)
                }
            }
        }

        for (position, color) in spawnPoints {
            let squareViewPos = squareViewPoint(for: position)
            let squarePos = point(for: position)
            drawBorder(point: squarePos, color: BoardView.colorToUIColor[color]!)
            drawSimpleStripes(x: squareViewPos.x, y: squareViewPos.y, width: squareViewLength, height: squareViewLength)
        }
    }

    private func drawBorder(point: CGPoint, color: UIColor) {
        let path = UIBezierPath(rect:
            CGRect(origin: point,
                    size: CGSize(width: squareLength, height: squareLength)))
        color.setStroke()
        path.lineWidth = strokeWidth
        path.stroke()
    }

    private func drawWall(point: CGPoint, wallSquare: SquareView) {
        let size = CGSize(width: squareViewLength, height: squareViewLength)
        wallSquare.frame = CGRect(origin: point, size: size)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.translateBy(x: point.x, y: point.y)
        wallSquare.layer.render(in: ctx)
        ctx.translateBy(x: -point.x, y: -point.y)
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

    override func layoutSubviews() {
        refreshSubviews()
    }

    func refreshSubviews() {
        subviews.forEach { $0.removeFromSuperview() }

        for x in 0..<board.boardState.columns {
            for y in 0..<board.boardState.rows {
                switch board.boardState[x, y] {
                case .empty:
                    break
                case .deadBody:
                    addSubview(newSquareView(x: x, y: y, color: .gray))
                case .square(let color):
                    addSubview(newSquareView(x: x, y: y, color: BoardView.colorToUIColor[color]!))
                }
            }
        }
    }

    func animateMoveResult(_ moveResult: MoveResult) {
        animationManager.reset()
        let dx: Int
        let dy: Int
        let unit = Double(squareLength)
        switch moveResult.direction {
        case .right:
            (dx, dy) = (1, 0)
        case .left:
            (dx, dy) = (-1, 0)
        case .down:
            (dx, dy) = (0, 1)
        case .up:
            (dx, dy) = (0, -1)
        }

        let movedSquares = moveResult.movedPositions.compactMap(squareView(atPosition:))
        let slippedSquares = moveResult.slippedPositions.compactMap(squareView(atPosition:))
        let fellSquares = moveResult.fellPositions.compactMap(squareView(atPosition:))
        let grayedOutSquares = moveResult.greyedOutPositions.compactMap(squareView(atPosition:))
    }

    private func squareView(atPosition position: Position) -> SquareView? {
        viewWithTag(viewTag(forPosition: position)) as? SquareView
    }

    private func viewTag(forPosition position: Position) -> Int {
        position.rawValue
    }

    private func position(fromTag tag: Int) -> Position {
        Position(rawValue: tag)!
    }

    private func newSquareView(x: Int, y: Int, color: UIColor) -> SquareView {
        let position = Position(x, y)
        let pos = squareViewPoint(for: position)
        let square = SquareView(frame: CGRect(origin: pos, size: CGSize(width: squareViewLength, height: squareViewLength)))
        square.backgroundColor = color
        square.tag = viewTag(forPosition: position)
        return square
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