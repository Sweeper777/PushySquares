import UIKit

class GameViewController: UIViewController, GameDelegate {

    @IBOutlet var boardView: GameBoardView!
    let game = Game(map: .standard, playerCount: 4)
    
    var swipeUpGR: UISwipeGestureRecognizer!
    var swipeDownGR: UISwipeGestureRecognizer!
    var swipeLeftGR: UISwipeGestureRecognizer!
    var swipeRightGR: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        boardView.game = self.game
        
        game.delegate = self
        
    }
    
    func playerDidMakeMove(direction: Direction?, originalPositions: [Position], destroyedSquarePositions: [Position], greyedOutPositions: [Position], newSquareColor: Color?) {
    }
}

