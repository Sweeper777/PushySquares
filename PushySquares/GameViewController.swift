import UIKit

class GameViewController: UIViewController {

    @IBOutlet var boardView: GameBoardView!
    let game = Game(map: .standard, playerCount: 4)
    
    override func viewDidLoad() {
        boardView.game = self.game
    }
}

