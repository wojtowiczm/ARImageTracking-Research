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
    static let tux = "tux"
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let referenceImages =  ARReferenceImage.referenceImages(inGroupNamed: "Images", bundle: Bundle.main)!
    var videoPlayer: AVPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        sceneView.scene = SCNScene(named: "art.scnassets/Game.scn")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func runConfiguration() {
        let configuration = ARImageTrackingConfiguration()
        
        // Setup image tracking
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = referenceImages.count
        sceneView.session.run(configuration)
    }
    
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
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        
        // Add white background
        plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.8)
        let planeNode = SCNNode(geometry: plane)
        
        // Rotate x axis - 90
        planeNode.eulerAngles.x = -.pi / 2
    
        switch imageAnchor.name {
        case TrackableImages.matrix: setupVideo(on: planeNode)
        case TrackableImages.tux: setupObject(on: planeNode)
        default: return nil
        }
        return planeNode
    }
    
    // Video node
    
    func setupVideo(on node: SCNNode) {
        guard let videoURL = Bundle.main.url(forResource: "MatrixTrailer", withExtension: "mov") else { return }
       
        // Create video player node
        videoPlayer = AVPlayer(url: videoURL)
        let videoPlayerNode: SKVideoNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayerNode.yScale = -1
        
        // Setup scene for player
        let spriteKitScene = SKScene(size: CGSize(width: 720, height: 1280))
        spriteKitScene.scaleMode = .aspectFit
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width / 2, y: spriteKitScene.size.height / 2)
        videoPlayerNode.size = spriteKitScene.size
        spriteKitScene.addChild(videoPlayerNode)
        
        // Add player to plane
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        videoPlayerNode.play()
    }
    
    // 3D Object node
    
    func setupObject(on node: SCNNode) {
        let penguinScene = SCNScene(named: "art.scnassets/ship.scn")!
        let penguinNode = penguinScene.rootNode.childNodes.first!
        penguinNode.position = SCNVector3Zero
        penguinNode.position.z = 0.15
        
        node.addChildNode(penguinNode)
    }
}
