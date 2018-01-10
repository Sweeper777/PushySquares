import FSPagerView
import UIKit

class GameBoardCell: FSPagerViewCell {
    @IBOutlet var gameBoardView: GameBoardView!
    @IBOutlet var lockedImage: UIImageView!
    var game: Game! {
        didSet {
            gameBoardView.game = game
        }
    }
    
    var locked: Bool = true {
        didSet {
            lockedImage.isHidden = !locked
        }
    }
}
