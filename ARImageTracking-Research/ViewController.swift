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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let referenceImages =  ARReferenceImage.referenceImages(inGroupNamed: "Images", bundle: Bundle.main)!
    //let player = AVPlayer(url: URL(string: "https://www.youtube.com/embed/rLl9XBg7wSs")!)
    let videoPlayer = AVPlayer(url: Bundle.main.url(forResource: "IMG_0377", withExtension: "MOV")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.scene = SCNScene(named: "art.scnassets/Game.scn")!
        loopVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = referenceImages.count
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.8)
            let planeNode = SCNNode(geometry: plane)
              planeNode.eulerAngles.x = -.pi / 2
            
            setupVideoOnNode(planeNode)
            node.addChildNode(planeNode)
        }
        
        return node
        
    }
    
    func setupVideoOnNode(_ node: SCNNode){
        
        let videoPlayerNode: SKVideoNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayerNode.yScale = -1

        let spriteKitScene = SKScene(size: CGSize(width: 720, height: 1280))
        spriteKitScene.scaleMode = .aspectFit
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        videoPlayerNode.size = spriteKitScene.size
        spriteKitScene.addChild(videoPlayerNode)
        
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene

        videoPlayerNode.play()
        videoPlayer.volume = 0
    
    }
    
    private func loopVideo() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem, queue: nil) { notification in
            self.videoPlayer.seek(to: CMTime.zero)
            self.videoPlayer.play()

            print("reset Video")
            
        }
    }
    
    private func videoNode(for image: ARReferenceImage) {
        
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
