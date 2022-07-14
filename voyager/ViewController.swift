//
//  ViewController.swift
//  voyager
//
//  Created by 지우석 on 2022/07/14.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var imgView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.frameSemantics = [.smoothedSceneDepth]
        
//        sceneView.preferredFramesPerSecond = 15
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// access to ARFrame obj for current timestamp
//        sceneView.session.currentFrame
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        guard let depthSmoothData = frame.smoothedSceneDepth else { return }
        
        let depthImgCI = CIImage(cvPixelBuffer: depthSmoothData.depthMap)
        
        let depthImgUI = UIImage(ciImage: depthImgCI.oriented(.right))
        imgView.image = depthImgUI
        
        
    }
}

