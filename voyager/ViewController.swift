//
//  ViewController.swift
//  voyager
//
//  Created by 지우석 on 2022/07/14.
//

import UIKit
import SceneKit
import ARKit
import Toast_Swift

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var imgView: UIImageView!
    
    var currentDepthMap: CVPixelBuffer?
    
    var arSession: ARSession!
    var depthSaver: DepthSaver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        self.arSession = sceneView.session
        self.depthSaver = DepthSaver(session: self.arSession)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !ARWorldTrackingConfiguration.isSupported {
            print("AR Configuration not supported")
            return
        }
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.frameSemantics = [.smoothedSceneDepth]
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func handleCaptureButton(_ sender: Any) {
        do {
            try depthSaver.saveDepthToCilpBoard()
            self.view.makeToast("LiDAR Sensor data copied to clipboard!")
        } catch {
            self.view.makeToast("Unable to retrieve LiDAR Sensor data!")
        }
    }
    
}

extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        guard let depthSmoothData = frame.smoothedSceneDepth else { return }

        currentDepthMap = depthSmoothData.depthMap
        
        let depthImgCI = CIImage(cvPixelBuffer: currentDepthMap!)
        
        imgView.image = UIImage(ciImage: depthImgCI.oriented(.right))
    }
}

