import SceneKit

class BoardSceneView: SCNView {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let scene = scene as? BoardScene else { return }
        let location = touch.preciseLocation(in: self)
        let prevLocation = touch.precisePreviousLocation(in: self)
        let dx = location.x - prevLocation.x
        scene.rotateCamera(Float(dx) / 100)
        setNeedsDisplay()
        super.touchesMoved(touches, with: event)
    }
}
