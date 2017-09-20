import UIKit
import JTImageButton

@IBDesignable
class ActionBar: UIView {
    @IBOutlet var quitButton: JTImageButton!
    @IBOutlet var restartButton: JTImageButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    private func setupView() {
        let view = viewFromNibForClass() as! UIStackView
        view.frame = bounds
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        addSubview(view)
        backgroundColor = .clear
        let buttonHeight = (view.height - view.spacing * (view.subviews.count.f - 1)) / view.subviews.count.f
        
        quitButton.borderWidth = 0
        quitButton.borderColor = .clear
        quitButton.bgColor = .red
        quitButton.titleColor = .white
        quitButton.iconColor = .white
        quitButton.createTitle("Quit", withIcon: #imageLiteral(resourceName: "quit"), font: UIFont.systemFont(ofSize: 12), iconOffsetY: 0)
        quitButton.touchEffectEnabled = true
        quitButton.cornerRadius = buttonHeight / 2
        
        restartButton.borderColor = .clear
        restartButton.bgColor = .red
        restartButton.titleColor = .white
        restartButton.iconColor = .white
        restartButton.createTitle("Restart", withIcon: #imageLiteral(resourceName: "restart"), font: UIFont.systemFont(ofSize: 12), iconOffsetY: 0)
        restartButton.touchEffectEnabled = true
        restartButton.cornerRadius = buttonHeight / 2
    }
    
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle.main
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
}
