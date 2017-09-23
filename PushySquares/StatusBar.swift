import UIKit
import FittableFontLabel
import SwiftyUtils

@IBDesignable
class StatusBar: UIView {
    @IBOutlet var imgNewSquareIn: UIImageView!
    @IBOutlet var imgCurrentTurn: SquareView!
    @IBOutlet var imgLives: UIImageView!
    
    @IBOutlet var currentTurnHeader: UILabel!
    
    func setNewSquareIn(value: Int) {
        let string = NSMutableAttributedString()
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        string.append(NSAttributedString(string: "NEW SQUARE IN:\n", attributes: [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 30)!,
            NSParagraphStyleAttributeName: paraStyle
            ]))
        string.append(NSAttributedString(string: value.description, attributes: [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 60)!,
            NSParagraphStyleAttributeName: paraStyle
            ]))
        imgNewSquareIn.image = imageFrom(string)
    }
    
    func setCurrentTurn(value: Color) {
        imgCurrentTurn.backgroundColor = GameBoardView.colorToUIColor[value]!
    }
    
    func setLives(players: [Player]) {
        let text = NSMutableAttributedString(string: "LIVES\n")
        let player1Lives = NSAttributedString(string: "♥︎", attributes: [NSForegroundColorAttributeName: GameBoardView.colorToUIColor[players[0].color]!])
        text.append(player1Lives)
        text.append(NSAttributedString(string: "\(players[0].lives) "))
        let player2Lives = NSAttributedString(string: "♥︎", attributes: [NSForegroundColorAttributeName: GameBoardView.colorToUIColor[players[1].color]!])
        text.append(player2Lives)
        text.append(NSAttributedString(string: "\(players[1].lives) "))
        if players.count > 2 {
            let player3Lives = NSAttributedString(string: "\n♥︎", attributes: [NSForegroundColorAttributeName: GameBoardView.colorToUIColor[players[2].color]!])
            text.append(player3Lives)
            text.append(NSAttributedString(string: "\(players[2].lives)"))
        }
        if players.count > 3 {
            let player4Lives = NSAttributedString(string: " ♥︎", attributes: [NSForegroundColorAttributeName: GameBoardView.colorToUIColor[players[3].color]!])
            text.append(player4Lives)
            text.append(NSAttributedString(string: "\(players[3].lives)"))
        }
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        text.addAttributes([
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 60)!,
            NSParagraphStyleAttributeName: paraStyle
            ], range: NSRange.init(location: 0, length: text.length))
        imgLives.image = imageFrom(text)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    private func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        addSubview(view)
        backgroundColor = .clear
        imgLives.contentMode = .scaleAspectFit
        
    }
    
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle.main
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    private func imageFrom(_ str: NSAttributedString) -> UIImage {
        let size = str.size()
        UIGraphicsBeginImageContext(size)
        str.draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
