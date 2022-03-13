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
        let configuration = ARWorldTrackingConfiguration()
        
        // Image detection
        configuration.detectionImages = ARReferenceImage
            .referenceImages(inGroupNamed: "AR Resources", bundle: nil)

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
    
    // MARK: - Methods
    
    private func overlayImage(inNode node: SCNNode, forAnchor imageAnchor: ARImageAnchor) {

        let image = imageAnchor.referenceImage
        let size = image.physicalSize
        let width = size.width
        let height = size.height
        
        let overlayMesh = SCNPlane(width: width, height: height)
        let texture = UIColor(red: 0, green: 1, blue: 0, alpha: 0.75)
        overlayMesh.firstMaterial?.diffuse.contents = texture
        
        let overlay = SCNNode(geometry: overlayMesh)
        overlay.eulerAngles.x = -.pi/2
        
        node.addChildNode(overlay)
    }
    
}
