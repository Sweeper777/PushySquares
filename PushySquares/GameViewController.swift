import UIKit

class GameViewController: UIViewController, GameDelegate {

    @IBOutlet var boardView: GameBoardView!
    let game = Game(map: .standard, playerCount: 4)
    
    override func viewDidLoad() {
        boardView.game = self.game
    }
    
    func playerDidMakeMove(direction: Direction?, originalPositions: [Position], destroyedSquarePositions: [Position], greyedOutPositions: [Position], newSquareColor: Color?) {
    }
}

