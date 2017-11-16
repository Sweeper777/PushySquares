import FSPagerView

class GameBoardCell: FSPagerViewCell {
    @IBOutlet var gameBoardView: GameBoardView!
    var game: Game! {
        didSet {
            gameBoardView.game = game
        }
    }
}
