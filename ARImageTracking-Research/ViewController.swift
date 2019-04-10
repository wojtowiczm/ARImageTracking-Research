//
//  ViewController.swift
//  ARImageTracking-Research
//
//  Created by Michał Wójtowicz on 27/03/2019.
//  Copyright © 2019 Michał Wójtowicz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum TrackableImages {
    static let matrix = "Matrix-Poster"
    static let ship = "SPACESHIP"
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var videoNode: SKVideoNode?
    
    lazy var sceneLight: SCNLight = {
        let light = SCNLight()
        light.type = .omni
        return light
    }()
    
    let referenceImages =  ARReferenceImage.referenceImages(inGroupNamed: "Images", bundle: Bundle.main)!
    var videoPlayer: AVPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func setupScene() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        sceneView.scene = SCNScene()//named: "art.scnassets/Game.scn")!
        

        let lightNode = SCNNode()
        lightNode.light = sceneLight
        lightNode.position = SCNVector3(x: 0, y: 10, z: 2)

        sceneView.scene.rootNode.addChildNode(lightNode)
    }
    
    private func runConfiguration() {
        let configuration = ARImageTrackingConfiguration()
        
        // Setup image tracking
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = referenceImages.count
        // configure light estimation
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let result = sceneView.hitTest(touch.location(in: sceneView)).last else { return }
        guard let videoNode = result.node as? SKVideoNode else { return }
    }
    
    // Update light
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let estimate = self.sceneView.session.currentFrame?.lightEstimate {
            sceneLight.intensity = estimate.ambientIntensity
        }
    }
    
    // Add object on detected images
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        guard let imageAnchor = anchor as? ARImageAnchor else { return node }
        // Generate proper node for anchor
        if let childNode = nodeFor(imageAnchor) {
            node.addChildNode(childNode)
        }
        return node
    }
    
    private func nodeFor(_ imageAnchor: ARImageAnchor) -> SCNNode? {
        
        // Setup plane with physical dimensions
        let plane = SCNPlane(
            width: imageAnchor.referenceImage.physicalSize.width,
            height: imageAnchor.referenceImage.physicalSize.height)
        
        // Add white background
        plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.8)
        let planeNode = SCNNode(geometry: plane)
        
        // Rotate x axis - 90
        planeNode.eulerAngles.x = -.pi / 2
    
        switch imageAnchor.name {
        case TrackableImages.matrix: setupVideo(on: planeNode)
        case TrackableImages.ship: setupObject(on: planeNode)
        default: return nil
        }
        return planeNode
    }
    
    // Video node
    
    func setupVideo(on node: SCNNode) {
        guard let videoURL = Bundle.main.url(forResource: "MatrixTrailer", withExtension: "mov") else { return }
       
        // Create video player node
        videoPlayer = AVPlayer(url: videoURL)
        videoNode = SKVideoNode(avPlayer: videoPlayer)
        videoNode?.yScale = -1
        
        // Setup scene for player
        let spriteKitScene = SKScene(size: CGSize(width: 720, height: 1280))
        spriteKitScene.scaleMode = .aspectFit
        videoNode?.position = CGPoint(
            x: spriteKitScene.size.width / 2,
            y: spriteKitScene.size.height / 2)
        videoNode?.size = spriteKitScene.size
        spriteKitScene.addChild(videoNode!)
        
        // Add player to plane
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        videoNode!.play()
    }
    
    // 3D Object node
    
    func setupObject(on node: SCNNode) {
        let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
        let shipNode = shipScene.rootNode.childNodes.first!
        shipNode.position = SCNVector3Zero
        shipNode.position.y = 0.15
        node.addChildNode(shipNode)
    }
}
