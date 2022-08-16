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
    
    // AR data objects
    var arSession: ARSession!
    var arReciever: ARReceiver!
    var lastArData: ARData?
    var depthSaver: DepthSaver!
    
    let fps = 1
    var loopClock: LoopClock!
    
    var server: Server!
    
    var depthGuider = DepthGuider()
    
    var speechGuider = SpeechGuider()
    
    /// configure data & service objects.
    /// set delegates.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics([.sceneDepth, .smoothedSceneDepth]) else {
            print("Unable to configure ARSession!")
            return
        }
        
        // Set the view's delegate
        sceneView.delegate = self
        
        arSession = sceneView.session
        arReciever = ARReceiver(session: self.arSession)
        arReciever.delegate = self
        depthSaver = DepthSaver(session: self.arSession)
        
        loopClock = LoopClock(fps: self.fps)
        loopClock.delegate = self
        
        server = Server(viewController: self)
        
        // set AVAudioSession for speaker sound output
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func handleCaptureButton(_ sender: Any) {
//        do {
//            try depthSaver.saveDepthToCilpBoard()
//            self.view.makeToast("LiDAR Sensor data copied to clipboard!")
//        } catch {
//            self.view.makeToast("Unable to retrieve LiDAR Sensor data!")
//        }

        if let depthImage = lastArData?.depthSmoothImage {
            let landscapeGuide = depthGuider.detectLandscape(depthImage: depthImage)
            switch landscapeGuide {
            case .cliff(let distance):
                self.view.makeToast(String(format: "추락지형! %.2f 미터", distance))
            case .wall(let distance):
                self.view.makeToast(String(format: "전방 장애물! %.2f 미터", distance))
            default:
                self.view.makeToast("지형 정상!")
                speechGuider.speak(string: "지형이 정상입니다.")
            }
            
        }
        displayDepthImage()
    }
    
    @IBAction func handleStartStopButton(_ sender: UIButton) {
        guideStartStopButton.isEnabled = false
        
        if !isGuiding {
            requestStartGuiding()
        } else {
            requestStopGuiding()
        }
    }
    
    func updateStartStopButton() {
        if isGuiding {
            guideStartStopButton.setTitle(K.stopButtonText, for: .normal)
        } else {
            guideStartStopButton.setTitle(K.startButtonText, for: .normal)
        }
    }
    
}

extension ViewController: ServerGuideDelegate {
    
    /// called when server recieves guidance from stateMachine
    func alertGuide(guide: [ServerGuideResponseRawData]) {
        if !guide.isEmpty {
            self.view.makeToast(guide.joined(separator: "\n"))
        }
    }
    
    /// call this before starting server guide
    func requestStartGuiding() {
        server.start()
    }
    
    /// delegate method; called by server when server acknowledges `requestStartGuiding()`
    func startGuiding() {
        self.alertGuide(guide: ["starting guide!"])
        
        isGuiding = true
        updateStartStopButton()
        guideStartStopButton.isEnabled = true
        
        loopClock.start()
    }
    
    /// call this before stoping server guide
    func requestStopGuiding() {
        server.stop()
    }
    
    /// delegate method; called by server when server acknowledges `requestStopGuiding()`
    func stopGuiding() {
        self.alertGuide(guide: ["stopping guide!"])
        
        isGuiding = false
        updateStartStopButton()
        guideStartStopButton.isEnabled = true
        
        loopClock.stop()
    }
    
}

extension ViewController: ARDataReceiver {
    
    /// called when AR data is updated
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
    
    /// called for every loopClock step
    func invoke(counter: Int) {
        print("loop clock invoked: \(loopClock.counter)")
        sendRGBImage(sequenceNo: counter)
    }
    
    func sendRGBImage(sequenceNo: Int = 0) {
        
        if let img = lastArData?.colorImage {
            let uploadData = ServerImageUploadData(sequenceNo: sequenceNo, image: img)
            server.send(imgData: uploadData)
        } else {
            self.view.makeToast("Unable to retrieve current RGB image!")
        }
    }
}
