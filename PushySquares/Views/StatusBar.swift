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

    func setNewSquareIn(_ value: Int) {
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: "NEW SQUARE IN:\n".localized, attributes: [
            .font: UIFont(name: "Chalkboard SE", size: 30)!,
            .paragraphStyle: centerAlignedParaStyle
        ]))
        string.append(NSAttributedString(string: value.description, attributes: [
            .font: UIFont(name: "Chalkboard SE", size: 60)!,
            .paragraphStyle: centerAlignedParaStyle
        ]))
        imgNewSquareIn.image = imageFrom(string)
    }

    func setCurrentTurn(_ value: Color) {
        imgCurrentTurn.backgroundColor = BoardView.colorToUIColor[value]!
    }

    func setLives(players: [Player]) {
        let text = NSMutableAttributedString(string: "LIVES\n".localized)
        let player1Lives = NSAttributedString(string: "♥︎", attributes: [.foregroundColor: BoardView.colorToUIColor[players[0].color]!])
        text.append(player1Lives)
        text.append(NSAttributedString(string: "\(players[0].lives) "))
        let player2Lives = NSAttributedString(string: "♥︎", attributes: [.foregroundColor: BoardView.colorToUIColor[players[1].color]!])
        text.append(player2Lives)
        text.append(NSAttributedString(string: "\(players[1].lives) "))
        if players.count > 2 {
            let player3Lives = NSAttributedString(string: "\n♥︎", attributes: [.foregroundColor: BoardView.colorToUIColor[players[2].color]!])
            text.append(player3Lives)
            text.append(NSAttributedString(string: "\(players[2].lives)"))
        }
        if players.count > 3 {
            let player4Lives = NSAttributedString(string: " ♥︎", attributes: [.foregroundColor: BoardView.colorToUIColor[players[3].color]!])
            text.append(player4Lives)
            text.append(NSAttributedString(string: "\(players[3].lives)"))
        }
        text.addAttributes([
            .font: UIFont(name: "Chalkboard SE", size: 60)!,
            .paragraphStyle: centerAlignedParaStyle
        ], range: NSRange(location: 0, length: text.length))
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
            .flexibleWidth,
            .flexibleHeight
        ]
        addSubview(view)
        backgroundColor = .clear
        imgLives.contentMode = .scaleAspectFit

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let fontSize = fontSizeThatFits(size: self.currentTurnHeader.frame.size, text: "TURN".localized as NSString, font: UIFont(name: "Chalkboard SE", size: 0)!)
            self.currentTurnHeader.font = self.currentTurnHeader.font.withSize(fontSize)
            self.currentTurnHeader.text = "TURN".localized
        }
    }

    private func viewFromNibForClass() -> UIView {

        let bundle = Bundle(for: StatusBar.self)
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
