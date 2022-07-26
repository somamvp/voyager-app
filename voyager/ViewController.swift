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

class ViewController: UIViewController, LoopClockDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var imgView: UIImageView!
    
    var currentDepthMap: CVPixelBuffer?
    
    var arSession: ARSession!
    var depthSaver: DepthSaver!
    
    let fps = 10
    lazy var loopClock: LoopClock = { LoopClock(fps: self.fps) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        self.arSession = sceneView.session
        self.depthSaver = DepthSaver(session: self.arSession)
        
        loopClock.delegate = self
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
        
        loopClock.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        loopClock.stop()
    }
    
    @IBAction func handleCaptureButton(_ sender: Any) {
        do {
            try depthSaver.saveDepthToCilpBoard()
            self.view.makeToast("LiDAR Sensor data copied to clipboard!")
        } catch {
            self.view.makeToast("Unable to retrieve LiDAR Sensor data!")
        }
    }
    
    func invoke() {
        print("loop clock invoked: \(loopClock.counter)")
    }
    
}

extension ViewController: ARSessionDelegate, ARSCNViewDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        guard let depthSmoothData = frame.smoothedSceneDepth else { return }

        currentDepthMap = depthSmoothData.depthMap
        
        let depthImgCI = CIImage(cvPixelBuffer: currentDepthMap!)
        
        imgView.image = UIImage(ciImage: depthImgCI.oriented(.right))
    }
}

