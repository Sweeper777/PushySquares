import FSPagerView
import UIKit
import PushySquaresModel

class GameBoardCell: FSPagerViewCell {
    @IBOutlet var boardView: BoardView!
    @IBOutlet var lockedImage: UIImageView!
    var board: BoardProvider! {
        didSet {
            boardView.board = board
        }
    }
    
    var locked: Bool = true {
        didSet {
            lockedImage.isHidden = !locked
        }
    }
}
