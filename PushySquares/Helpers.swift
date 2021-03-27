import UIKit

fileprivate func shouldContinueToEnlarge(targetSize: CGSize, currentSize: CGSize) -> Bool {
    return targetSize.height > currentSize.height && targetSize.width > currentSize.width
}

func fontSizeThatFits(size: CGSize, text: NSString, font: UIFont) -> CGFloat {
    var fontToTest = font.withSize(0)
    var currentSize = text.size(withAttributes: [NSAttributedString.Key.font: fontToTest])
    var fontSize = CGFloat(1)
    while shouldContinueToEnlarge(targetSize: size, currentSize: currentSize) {
        fontToTest = fontToTest.withSize(fontSize)
        currentSize = text.size(withAttributes: [NSAttributedString.Key.font: fontToTest])
        fontSize += 1
    }
    return fontSize - 1
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

extension UIColor {
    func image(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 56, height: 56), false, 0)
        setFill()
        let path = UIBezierPath(ovalIn: CGRect.zero.with(size: size))
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}