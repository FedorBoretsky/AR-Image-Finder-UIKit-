//
//  ViewController.swift
//  AR Image Finder
//
//  Created by Fedor Boretskiy on 12.03.2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Properties
    
    let videoPlayer: AVPlayer = {
        let url = Bundle.main.url(
            forResource: "aboutRUB",
            withExtension: "mp4",
            subdirectory: "art.scnassets"
        )!
        return AVPlayer(url: url)
    }()
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // Image detection
        configuration.maximumNumberOfTrackedImages = 3
        configuration.trackingImages = ARReferenceImage
            .referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        switch anchor {
        case let imageAnchor as ARImageAnchor:
            overlayImage(inNode: node, forAnchor: imageAnchor)
        default:
            print(anchor)
        }
    }
    
    // MARK: - Overlay banknote methods
    
    private func overlayImage(inNode node: SCNNode, forAnchor imageAnchor: ARImageAnchor) {
        // Supporting recognized image
        let image = imageAnchor.referenceImage
        var isTheatre: Bool { image.name == "theatre" }
        
        // 100 rub size
        let size = image.physicalSize
        let height = size.height
        let theatreWidth = size.width * (15 / 5.7149)
        let horsesWidth = size.width * (15 / 6.0345)
        let width = (isTheatre) ? theatreWidth : horsesWidth
        
        // 5000 rub size
        let overlayWidth = width * (157 / 150)
        let overlayHeight = height * (69 / 65)
        
        // Create overlay mesh
        let overlayMesh = SCNPlane(width: overlayWidth, height: overlayHeight)
        let texture =  isTheatre ? videoPlayer : UIImage(named: "monument")
        if isTheatre {
            videoPlayer.play()
        }
        overlayMesh.firstMaterial?.diffuse.contents = texture
        
        // Create overlay node
        let overlay = SCNNode(geometry: overlayMesh)
        overlay.eulerAngles.x = -.pi/2
        let theatreShift: Float = 0.01
        let horsesShift: Float = -0.01
        overlay.position.x += (isTheatre) ? theatreShift : horsesShift
        
        // Disappearing
        overlay.runAction(.sequence([
            .wait(duration: 5),
            .fadeOut(duration: 3),
            .removeFromParentNode(),
        ]))
        
        // Show ovarlay
        node.addChildNode(overlay)
    }
    
}
