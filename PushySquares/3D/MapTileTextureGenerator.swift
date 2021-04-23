import UIKit
import PushySquaresModel
import SceneKit

enum MapTileTextureGenerator {
    private static var mapTileMaterialCache: [MapTile: SCNMaterial] = [:]
    private static var colorMaterialCache: [UIColor: SCNMaterial] = [:]

    static func material(for mapTile: MapTile) -> SCNMaterial? {
        if let cached = mapTileMaterialCache[mapTile] {
            return cached
        }

        if mapTile == .void {
            return nil
        }

        if mapTile == .slippery {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "wet")
            mapTileMaterialCache[mapTile] = material
            return material
        }

        let size = 500.f
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        defer { UIGraphicsEndImageContext() }

        UIColor(hex: "fff4d0").setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size, height: size))

        if mapTile != .wall {
            drawSimpleStripes(x: 0, y: 0, width: size, height: size, strokeWidth: size / 8)
        }

        let strokeColor: UIColor
        if mapTile == .ground || mapTile == .wall{
            strokeColor = .black
        } else if case .spawnpoint(let color) = mapTile {
            strokeColor = BoardView.colorToUIColor[color]!
        } else {
            fatalError("This shouldn't happen!")
        }

        strokeColor.setStroke()
        let border = UIBezierPath(rect: CGRect(x: 0, y: 0, width: size, height: size))
        border.lineWidth = size / 8
        border.stroke()

        let image = UIGraphicsGetImageFromCurrentImageContext()!.flipImage()!

        let material = SCNMaterial()
        material.diffuse.contents = image

        mapTileMaterialCache[mapTile] = material
        return material
    }

    static func material(for color: UIColor) -> SCNMaterial {
        if let cached = colorMaterialCache[color] {
            return cached
        }
        let material = SCNMaterial()
        material.diffuse.contents = color
        colorMaterialCache[color] = material
        return material
    }
}

extension UIImage {
    func flipImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let bitmap = UIGraphicsGetCurrentContext()!

        bitmap.translateBy(x: size.width / 2, y: size.height / 2)
        bitmap.scaleBy(x: -1.0, y: -1.0)

        bitmap.translateBy(x: -size.width / 2, y: -size.height / 2)
        bitmap.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}