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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var imgView: UIImageView!
    
    var currentDepthMap: CVPixelBuffer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
    }
    
    @IBAction func handleCaptureButton(_ sender: Any) {
        guard let currentDepthMap = currentDepthMap else {
            view.makeToast("Unable to retrieve LiDAR Sensor data!")
            return
        }

        let depthAsArray = get2DimArrayFromDepthMap(depth: currentDepthMap)
        UIPasteboard.general.string = getStringFrom2DimArray(array: depthAsArray,
                                                             height: CVPixelBufferGetHeight(currentDepthMap),
                                                             width: CVPixelBufferGetWidth(currentDepthMap))
        view.makeToast("LiDAR Sensor data copied to clipboard!")
    }
    
    func get2DimArrayFromDepthMap(depth: CVPixelBuffer) -> [[Float32]] {
        let depthWidth = CVPixelBufferGetWidth(depth)
        let depthHeight = CVPixelBufferGetHeight(depth)
        
        CVPixelBufferLockBaseAddress(depth, CVPixelBufferLockFlags(rawValue: 0))
        
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depth),to: UnsafeMutablePointer<Float32>.self)
        
        var depthArray = [[Float32]]()
        
        for y in 0...depthHeight-1 {
            var distancesLine = [Float32]()
            for x in 0...depthWidth-1 {
                let distanceAtXYPoint = floatBuffer[y * depthWidth + x]
                distancesLine.append(distanceAtXYPoint)
                print("Depth in (\(x),\(y)): \(distanceAtXYPoint)")
            }
            depthArray.append(distancesLine)
        }
        
        return depthArray
    }
    // Read more at https://www.it-jim.com/blog/iphones-12-pro-lidar-how-to-get-and-interpret-data/
    
    // Auxiliary function to make String from depth map array
    func getStringFrom2DimArray(array: [[Float32]], height: Int, width: Int) -> String{
        var arrayStr: String = ""
        
        for y in 1...height-1 {
            var lineStr = ""
            
            for x in 1...width-1 {
                
                lineStr += String(array[y][x])
                if x != width-1 {
                    lineStr += ","
                }
            }
            lineStr += "\n"
            arrayStr += lineStr
        }
        return arrayStr
    }
    // Read more at https://www.it-jim.com/blog/iphones-12-pro-lidar-how-to-get-and-interpret-data/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !ARWorldTrackingConfiguration.isSupported {
            print("AR Configuration not supported")
            return
        }
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.frameSemantics = [.smoothedSceneDepth]
        
        /// adjust frames for sceneview
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

        currentDepthMap = depthSmoothData.depthMap
        
        let depthImgCI = CIImage(cvPixelBuffer: currentDepthMap!)
        
        imgView.image = UIImage(ciImage: depthImgCI.oriented(.right))
    }
}

