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
    }
    
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle.main
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
}
