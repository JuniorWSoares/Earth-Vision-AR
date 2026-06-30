import ARKit
import SceneKit
import ModelIO
import UIKit
import Flutter

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - EarthARView
// Usa ARKit + SceneKit + ModelIO para carregar .glb com texturas
// ─────────────────────────────────────────────────────────────────────────────
class EarthARView: NSObject, FlutterPlatformView, ARSCNViewDelegate {

    private let sceneView: ARSCNView
    private let channel: FlutterMethodChannel
    private var earthNode: SCNNode?

    private var lastPan: CGPoint = .zero
    private var currentScale: Float = 1.0
    private var baseScale: Float = 1.0
    private let defaultScale: Float = 0.001

    private lazy var arConfig: ARWorldTrackingConfiguration = {
        let c = ARWorldTrackingConfiguration()
        c.planeDetection = [.horizontal]
        c.isLightEstimationEnabled = true
        return c
    }()

    // ─────────────────────────────────────────────────────────────────
    init(frame: CGRect, channel: FlutterMethodChannel) {
        self.channel = channel
        sceneView = ARSCNView(frame: frame)
        super.init()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.antialiasingMode = .multisampling4X
        sceneView.session.run(arConfig)
        setupGestures()
    }

    func view() -> UIView { sceneView }

    func pauseSession() { sceneView.session.pause() }
    func resumeSession() { sceneView.session.run(arConfig, options: []) }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Gestos
    // ─────────────────────────────────────────────────────────────────
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView.addGestureRecognizer(pinch)
    }

    @objc private func handleTap(_ g: UITapGestureRecognizer) {
        let loc = g.location(in: sceneView)

        if let query = sceneView.raycastQuery(from: loc,
                                               allowing: .estimatedPlane,
                                               alignment: .horizontal),
           let hit = sceneView.session.raycast(query).first {
            placeEarth(at: hit.worldTransform)
            return
        }
        if let hit = sceneView.hitTest(loc, types: .estimatedHorizontalPlane).first {
            placeEarth(at: hit.worldTransform)
        }
    }

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        guard let node = earthNode else { return }
        switch g.state {
        case .began:
            node.removeAnimation(forKey: "spin")
            lastPan = .zero
        case .changed:
            let t = g.translation(in: sceneView)
            let dx = Float(t.x - lastPan.x) * 0.012
            let dy = Float(t.y - lastPan.y) * 0.012
            node.simdLocalRotate(by: simd_quatf(angle: dx, axis: SIMD3(0,1,0)))
            node.simdLocalRotate(by: simd_quatf(angle: dy, axis: SIMD3(1,0,0)))
            lastPan = t
        case .ended, .cancelled:
            startSpin(node)
        default: break
        }
    }

    @objc private func handlePinch(_ g: UIPinchGestureRecognizer) {
        guard let node = earthNode else { return }
        if g.state == .began { baseScale = currentScale }
        if g.state == .changed {
            currentScale = max(0.3, min(3.0, baseScale * Float(g.scale)))
            let s = defaultScale * currentScale
            node.scale = SCNVector3(s, s, s)
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Posiciona a Terra
    // ─────────────────────────────────────────────────────────────────
    private func placeEarth(at transform: simd_float4x4) {
        earthNode?.removeFromParentNode()
        currentScale = 1.0
        channel.invokeMethod("onLoading", arguments: nil)

        DispatchQueue.global(qos: .userInitiated).async {
            let node = self.loadGLBNode() ?? self.buildFallbackEarth()
            DispatchQueue.main.async {
                var t = transform
                t.columns.3.y += 0.005
                node.simdWorldTransform = t
                node.scale = SCNVector3(self.defaultScale,
                                        self.defaultScale,
                                        self.defaultScale)
                self.sceneView.scene.rootNode.addChildNode(node)
                self.earthNode = node
                self.startSpin(node)
                self.channel.invokeMethod("onEarthPlaced", arguments: nil)
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Carrega GLB via ModelIO (suporta .glb com texturas)
    // ─────────────────────────────────────────────────────────────────
    private func loadGLBNode() -> SCNNode? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // Tenta .usdz primeiro (textura PBR completa), depois .glb
        let candidates = [("earth", "usdz"), ("earth", "glb")]

        for (name, ext) in candidates {
            let dest = docs.appendingPathComponent("\(name).\(ext)")
            try? FileManager.default.removeItem(at: dest)

            if let src = Bundle.main.url(forResource: name, withExtension: ext) {
                try? FileManager.default.copyItem(at: src, to: dest)
                print("✅ Copiado \(name).\(ext) do bundle")
            }

            guard FileManager.default.fileExists(atPath: dest.path) else { continue }

            let size = (try? FileManager.default.attributesOfItem(atPath: dest.path)[.size] as? Int) ?? 0
            print("✅ Carregando \(name).\(ext) (\(size/1024)KB)...")

            if let src = SCNSceneSource(url: dest, options: [
                SCNSceneSource.LoadingOption.checkConsistency: false,
                SCNSceneSource.LoadingOption.createNormalsIfAbsent: true,
            ]), let scene = try? src.scene(options: nil) {
                let root = SCNNode()
                for child in scene.rootNode.childNodes {
                    root.addChildNode(child)
                }
                if !root.childNodes.isEmpty {
                    print("✅ Carregado com sucesso! Nós: \(root.childNodes.count)")
                    return root
                }
            }
            print("⚠️ \(ext) falhou, tentando próximo...")
        }

        print("❌ Nenhum formato carregou")
        return nil
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Rotação automática
    // ─────────────────────────────────────────────────────────────────
    private func startSpin(_ node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue   = NSValue(scnVector4: SCNVector4(0,1,0,0))
        spin.toValue     = NSValue(scnVector4: SCNVector4(0,1,0,Float.pi*2))
        spin.duration    = 24
        spin.repeatCount = .infinity
        spin.isRemovedOnCompletion = false
        node.addAnimation(spin, forKey: "spin")
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Fallback — esfera com textura NASA
    // ─────────────────────────────────────────────────────────────────
    private func buildFallbackEarth() -> SCNNode {
        print("⚠️ Usando fallback procedural")
        let node = SCNNode()
        let sphere = SCNSphere(radius: 80)   // escala compatível com defaultScale
        sphere.segmentCount = 96
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents  = UIImage(named: "earth_texture")
                                ?? UIColor(red:0.08, green:0.3, blue:0.75, alpha:1)
        mat.roughness.contents = UIColor(white: 0.6, alpha: 1)
        mat.metalness.contents = UIColor(white: 0.02, alpha: 1)
        sphere.materials = [mat]
        node.geometry = sphere

        // Atmosfera
        let atmo = SCNSphere(radius: 85)
        let atmoMat = SCNMaterial()
        atmoMat.diffuse.contents = UIColor(red:0.3, green:0.6, blue:1, alpha:0.1)
        atmoMat.isDoubleSided = true
        atmoMat.lightingModel = .constant
        atmo.materials = [atmoMat]
        node.addChildNode(SCNNode(geometry: atmo))
        return node
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: ARSCNViewDelegate — planos
    // ─────────────────────────────────────────────────────────────────
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let plane = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(makePlaneGrid(for: plane))
        DispatchQueue.main.async {
            self.channel.invokeMethod("onPlaneDetected", arguments: nil)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = anchor as? ARPlaneAnchor,
              let grid = node.childNodes.first else { return }
        updateGrid(grid, for: plane)
    }

    private func makePlaneGrid(for plane: ARPlaneAnchor) -> SCNNode {
        let geo = SCNPlane(width:  CGFloat(max(plane.extent.x, 0.05)),
                           height: CGFloat(max(plane.extent.z, 0.05)))
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(red:0, green:0.88, blue:1, alpha:0.12)
        mat.isDoubleSided = true
        geo.materials = [mat]
        let n = SCNNode(geometry: geo)
        n.eulerAngles.x = -.pi / 2
        n.simdPosition  = SIMD3(plane.center.x, 0, plane.center.z)
        return n
    }

    private func updateGrid(_ node: SCNNode, for plane: ARPlaneAnchor) {
        if let geo = node.geometry as? SCNPlane {
            geo.width  = CGFloat(max(plane.extent.x, 0.05))
            geo.height = CGFloat(max(plane.extent.z, 0.05))
        }
        node.simdPosition = SIMD3(plane.center.x, 0, plane.center.z)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Factory
// ─────────────────────────────────────────────────────────────────────────────
class EarthARViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    init(messenger: FlutterBinaryMessenger) { self.messenger = messenger; super.init() }

    func create(withFrame frame: CGRect,
                viewIdentifier viewId: Int64,
                arguments args: Any?) -> FlutterPlatformView {
        let ch = FlutterMethodChannel(name: "earth_ar_view_\(viewId)",
                                       binaryMessenger: messenger)
        return EarthARView(frame: frame, channel: ch)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}
