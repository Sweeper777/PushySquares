import UIKit
import PushySquaresModel

class ViewController: UIViewController {

    @IBOutlet var board: BoardView!
    override func viewDidLoad() {
        super.viewDidLoad()
        board.board = Game(map: .standard, playerCount: 4)

    }
}

