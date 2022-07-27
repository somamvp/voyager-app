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
    var arReciever: ARReceiver!
    var lastArData: ARData?
    var depthSaver: DepthSaver!
    
    let fps = 10
    lazy var loopClock: LoopClock = { LoopClock(fps: self.fps) }()
    
    var server = Server()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        arReciever = ARReceiver(session: sceneView.session)
        arReciever.delegate = self
        
        self.arSession = sceneView.session
        self.depthSaver = DepthSaver(session: self.arSession)
        
        loopClock.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
}

extension ViewController: ARDataReceiver {
    func onNewARData(arData: ARData) {
        lastArData = arData
        displayDepthImage()
    }
    
    func displayDepthImage() {
        
        guard let currentDepthMap = lastArData?.depthSmoothImage else { return }
        
        let depthImgCI = CIImage(cvPixelBuffer: currentDepthMap)
        
        imgView.image = UIImage(ciImage: depthImgCI.oriented(.right))
    }
}

extension ViewController: LoopClockDelegate {
    
    func invoke(counter: Int) {
        print("loop clock invoked: \(loopClock.counter)")
        
        if let img = lastArData?.colorImage {
            let uploadData = ServerImageUploadData(sequenceNo: counter, image: img)
            server.send(imgData: uploadData)
        } else {
            self.view.makeToast("Unable to retrieve current RGB image!")
        }
    }
}

