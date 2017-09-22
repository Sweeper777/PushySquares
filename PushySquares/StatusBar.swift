import UIKit
import FittableFontLabel
import SwiftyUtils

@IBDesignable
class StatusBar: UIView {
    @IBOutlet var lblNewSquareIn: FittableFontLabel!
    @IBOutlet var imgCurrentTurn: SquareView!
    @IBOutlet var lblLives: FittableFontLabel!
    
    func setNewSquareIn(value: Int) {
        lblNewSquareIn.text = value.description
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
    }
    
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle.main
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
}
