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
    
    @IBOutlet weak var guideStartStopButton: UIButton!
    var isGuiding = false
    
    var currentDepthMap: CVPixelBuffer?
    
    var arSession: ARSession!
    var arReciever: ARReceiver!
    var lastArData: ARData?
    var depthSaver: DepthSaver!
    
    let fps = 1
    lazy var loopClock: LoopClock = { LoopClock(fps: self.fps) }()
    
    var server: Server!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics([.sceneDepth, .smoothedSceneDepth]) else {
            print("Unable to configure ARSession!")
            return
        }
        
        // Set the view's delegate
        sceneView.delegate = self
        
        arReciever = ARReceiver(session: sceneView.session)
        arReciever.delegate = self
        
        self.arSession = sceneView.session
        self.depthSaver = DepthSaver(session: self.arSession)
        
        loopClock.delegate = self
        
        server = Server(viewController: self)
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
    
    func toggleStartStopButton() {
        if (isGuiding) {
            guideStartStopButton.setTitle(K.stopButtonText, for: .normal)
        } else {
            guideStartStopButton.setTitle(K.startButtonText, for: .normal)
        }
    }
    
    @IBAction func handleStartStopButton(_ sender: UIButton) {
        self.isGuiding.toggle()
        toggleStartStopButton()
        if (isGuiding) {
            startGuiding()
        } else {
            stopGuiding()
        }
    }
    
    func startGuiding() {
        server.start()
        
        loopClock.start()
    }
    
    func stopGuiding() {
        server.stop()
        
        loopClock.stop()
    }
    
}

extension ViewController: ServerGuideDelegate {
    
    func alertGuide(guide: [ServerGuideResponseRawData]) {
        if (!guide.isEmpty) {
            self.view.makeToast(guide.joined(separator: "\n"))
        }
    }
    
}

extension ViewController: ARDataReceiver {
    
    func onNewARData(arData: ARData) {
        lastArData = arData
//        displayDepthImage()
    }
    
    func displayDepthImage() {
        
        guard let currentDepthMap = lastArData?.depthSmoothImage else { return }
        
        let depthImgCI = CIImage(cvPixelBuffer: currentDepthMap)
        
        imgView.image = UIImage(ciImage: depthImgCI.oriented(.right))
    }
}

extension ViewController: LoopClockDelegate {
    
    func sendRGBImage(sequenceNo: Int = 0) {
        
        if let img = lastArData?.colorImage {
            let uploadData = ServerImageUploadData(sequenceNo: sequenceNo, image: img)
            server.send(imgData: uploadData)
        } else {
            self.view.makeToast("Unable to retrieve current RGB image!")
        }
    }
    
    func invoke(counter: Int) {
        print("loop clock invoked: \(loopClock.counter)")
        sendRGBImage(sequenceNo: counter)
    }
}

