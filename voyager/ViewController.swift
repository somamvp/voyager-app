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

class ViewController: UIViewController {
    
    @IBOutlet weak var guideStartStopButton: UIButton!
    var isGuiding = false
    
    // ARKit/AVFoundation data objects
    var useAVCaptureSession = true
    var sessionController: SessionController!
    lazy var sceneView: SceneView = { sessionController.createView() }()
    var lastCapturedData: CapturedData?
    var depthSaver: DepthSaver!
    
    let fps = 1
    var loopClock: LoopClock!
    
    var server: Server!
    
    var depthGuider = DepthGuider()
    
    var audioGuider = AudioGuider()
    
    /// configure data & service objects.
    /// set delegates.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if useAVCaptureSession {
            sessionController = AVSessionController()
        } else {
            sessionController = ARSessionController()
        }
        sessionController.delegate = self
        
        view.insertSubview(sceneView, at: 0)
        
        configureServices()
        
        sessionController.start()
    }
    
    func configureServices() {
        
        // TODO
        //        depthSaver = DepthSaver(session: self.arSession)
        
        // set LoopClock for repeating clock services
        loopClock = LoopClock(fps: self.fps)
        loopClock.delegate = self
        
        // set Server for backend networking
        server = Server(viewController: self)
        
        // set AVAudioSession for speaker sound output
        // https://stackoverflow.com/questions/69427369/avspeechsynthesizer-plays-sound-with-phone-call-speaker-instead-of-bottom-speake
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [])
        
        // set toast message config
        var style = ToastStyle()
        style.messageFont = .systemFont(ofSize: 18)
        ToastManager.shared.style = style
    }
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sessionController.stop()
    }
        
    func guide(_ string: String, duration: Double = 2.0) {
        self.view.makeToast(string, duration: duration, position: .center)
        audioGuider.speak(string: string)
    }
    
    @IBAction func handleCaptureButton(_ sender: Any) {
        if let depthImage = lastCapturedData?.depthSmoothImage {
            let landscapeGuide = depthGuider.detectLandscape(depthImage: depthImage)
            switch landscapeGuide {
            case .cliff(let distance):
                guide(String(format: "%.1f 미터 앞에 추락지형이 있습니다", distance))
            case .wall(let distance):
                guide(String(format: "%.1f 미터 앞에 장애물이 있습니다", distance))
            default:
                guide("지형이 정상입니다")
            }
            
        }
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
            self.guide(guide.joined(separator: "\n"), duration: 4.0)
        }
    }
    
    /// call this before starting server guide
    func requestStartGuiding() {
        server.start()
    }
    
    /// delegate method; called by server when server acknowledges `requestStartGuiding()`
    func startGuiding() {
        self.alertGuide(guide: ["보행 안내를 시작합니다."])
        
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
        self.alertGuide(guide: ["보행 안내를 종료합니다."])
        
        isGuiding = false
        updateStartStopButton()
        guideStartStopButton.isEnabled = true
        
        loopClock.stop()
    }
    
}

extension ViewController: SessionDataReceiver {
    
    /// called when AR/AV data is updated
    func onNewData(capturedData: CapturedData) {
        lastCapturedData = capturedData
//        displayDepthImage()
    }
    
    func onNewPhotoData(capturedData: CapturedData) {
        lastCapturedData = capturedData
//        displayDepthImage()
    }
    
    func displayDepthImage() {
        
        guard let currentDepthMap = lastCapturedData?.depthSmoothImage else { return }
        
        let depthImgCI = CIImage(cvPixelBuffer: currentDepthMap)
        
//        imgView.image = UIImage(ciImage: depthImgCI.oriented(.right))
    }
}

extension ViewController: LoopClockDelegate {
    
    /// called for every loopClock step
    func invoke(counter: Int) {
        print("loop clock invoked: \(loopClock.counter)")
        sendRGBImage(sequenceNo: counter)
    }
    
    func sendRGBImage(sequenceNo: Int = 0) {
        
        if let img = lastCapturedData?.colorImage {
            let uploadData = ServerImageUploadData(sequenceNo: sequenceNo, image: img)
            server.send(imgData: uploadData)
        } else {
            self.view.makeToast("Unable to retrieve current RGB image!")
        }
    }
}
