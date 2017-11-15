import UIKit

extension Map {
    func image(of size: CGSize) -> UIImage {
        let gameBoardView = GameBoardView(frame: CGRect.zero.with(size: size))
        gameBoardView.game = Game(map: self, playerCount: 4)
        UIGraphicsBeginImageContext(size)
        gameBoardView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
