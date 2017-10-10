import UIKit

class ButtonImageView: UIImageView {
    
    var onClick: (() -> ())?
    
    var imageRect: CGRect {
        let imageViewSize = self.frame.size
        let imgSize = self.image?.size
        
        guard let imageSize = imgSize, imgSize != nil else {
            return CGRect.zero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        // Center image
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
        
        return imageRect
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if imageRect.contains(touch.location(in: self)) {
                self.subviews.forEach { $0.removeFromSuperview() }
                let shade = UIView(frame: imageRect)
                shade.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
                self.addSubview(shade)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.subviews.forEach { $0.removeFromSuperview() }
        if let touch = touches.first {
            if imageRect.contains(touch.location(in: self)) {
                onClick?()
            }
        }
    }
}
