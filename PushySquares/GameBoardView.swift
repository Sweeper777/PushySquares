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
            self.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let game = self.game else { return }
        for x in 0..<game.board.columns {
            for y in 0..<game.board.rows {
                if case .void = game.board[x, y] {} else {
                    let path = UIBezierPath(rect: CGRect(origin: point(for: Position(x, y)), size: CGSize(width: squareLength, height: squareLength)))
                    UIColor.black.setStroke()
                    path.lineWidth = strokeWidth
                    path.stroke()
                }
            }
        }
        
        let wallsLocations = game.board.indicesOf { (tile) -> Bool in
            if case .wall = tile {
                return true
            } else {
                return false
            }
        }
        
        for position in wallsLocations {
            addSquareView(at: position, color: .white)
        }
        
        for color in [Color.color1, .color2, .color3, .color4] {
            let locations = game.board.indicesOf(color: color)
            for position in locations {
                addSquareView(at: position, color: GameBoardView.colorToUIColor[color]!)
            }
        }
    }
    
    func addSquareView(at position: Position, color: UIColor) {
        let squareView = SquareView(frame: CGRect(origin: squareViewPoint(for: position), size: CGSize(width: squareViewLength , height: squareViewLength)))
        squareView.backgroundColor = color
        let borderFactor = 1.0 / GameBoardView.borderSize
        let lengthMultiplier = 1.0 / (game!.board.columns.f * borderFactor + borderFactor + game!.board.columns.f)
        let heightConstraint = NSLayoutConstraint(item: squareView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: lengthMultiplier, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: squareView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: lengthMultiplier, constant: 0)
        squareView.tag = position.hashValue
        self.addSubview(squareView)
        self.addConstraints([heightConstraint, widthConstraint])
    }
    
    private func point(for position: Position) -> CGPoint {
        return CGPoint(x: strokeWidth / 2 + position.x.f * squareLength, y: strokeWidth / 2 + position.y.f * squareLength)
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
    
    func squareViewPoint(for position: Position) -> CGPoint {
        let pointForPosition = point(for: position)
        let offset = squareLength / GameBoardView.borderSize / 2
        return CGPoint(x: pointForPosition.x + offset, y: pointForPosition.y + offset)
    }
    
    func position(forViewTag tag: Int) -> Position {
        return Position(tag / 1000, tag % 1000)
    }
}
