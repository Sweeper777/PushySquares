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
    
    static let colorToString: [Color: String] = [
        .color1: "Red".localized,
        .color2: "Blue".localized,
        .color3: "Green".localized,
        .color4: "Yellow".localized
    ]
    
    static let borderSize: CGFloat = 8
    
    weak var game: Game? {
        didSet {
            setNeedsDisplay()
            self.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    func refreshSquareViews() {
        guard let game = self.game else { return }
        self.subviews.forEach { $0.removeFromSuperview() }
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
        
        for color in [Color.color1, .color2, .color3, .color4, .grey] {
            let locations = game.board.indicesOf(color: color)
            for position in locations {
                addSquareView(at: position, color: GameBoardView.colorToUIColor[color]!)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let game = self.game else { return }
        
        self.subviews.forEach { $0.removeFromSuperview() }
        
        func simpleStripes(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
            
            let stripeWidth: CGFloat = strokeWidth // whatever you want
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
        
//        UIColor(patternImage: #imageLiteral(resourceName: "texture").ResizeImage(targetSize: CGSize(width: strokeWidth * 2, height: strokeWidth * 2))).setFill()
        for x in 0..<game.board.columns {
            for y in 0..<game.board.rows {
                if case .void = game.board[x, y] {} else {
                    let path = UIBezierPath(rect: CGRect(origin: point(for: Position(x, y)), size: CGSize(width: squareLength, height: squareLength)))
                    UIColor.black.setStroke()
                    path.lineWidth = strokeWidth
                    path.fill()
                    path.stroke()
                    
                    let pointForSquareView = squareViewPoint(for: Position(x, y))
//
//                    let T: CGFloat = 3     // desired thickness of lines
//                    let G: CGFloat = 3     // desired gap between lines
//                    let W = squareViewLength
//                    let H = squareViewLength
//
//                    guard let c = UIGraphicsGetCurrentContext() else { return }
//                    c.setStrokeColor(UIColor.orange.cgColor)
//                    c.setLineWidth(T)
//
//                    var p = -(W > H ? W : H) - T
//                    while p <= W {
//
//                        c.move( to: CGPoint(x: pointForSquareView.x + p-T, y: pointForSquareView.y + -T) )
//                        c.addLine( to: CGPoint(x: pointForSquareView.x + p+T+H, y: pointForSquareView.y + T+H) )
//                        c.strokePath()
//                        p += G + T + T
//                    }
                }
            }
        }
        
        for slipperyPosition in game.slipperyPositions {
            let pt = point(for: slipperyPosition)
            let size = CGSize(width: squareLength, height: squareLength)
            #imageLiteral(resourceName: "wet").draw(in: CGRect(origin: pt, size: size))
        }
        
        refreshSquareViews()
        for color in [Color.color1, .color2, .color3, .color4, .grey] {
            if let spawnpoint = game.spawnpoints[color] {
                let path = UIBezierPath(rect: CGRect(origin: point(for: Position(spawnpoint.x, spawnpoint.y)), size: CGSize(width: squareLength, height: squareLength)))
                GameBoardView.colorToUIColor[color]?.setStroke()
                path.lineWidth = strokeWidth
                path.stroke()
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

extension UIImage {
    func resized(toWidth newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIImage {
    
    func ResizeImage(targetSize: CGSize) -> UIImage
    {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width,height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
