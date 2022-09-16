//
//  SessionController.swift
//  voyager
//
//  Created by 지우석 on 2022/09/16.
//

import ARKit

protocol SessionController {
    
    var delegate: SessionDataReceiver? { get set }
    
    func createView() -> SceneView
    
    func start()
    
    func stop()
}

protocol SessionDataReceiver: AnyObject {
    func onNewData(capturedData: CapturedData)
    func onNewPhotoData(capturedData: CapturedData)
}

// Store depth-related ARKit/AVFoundation frame data.
final class CapturedData {
    var depthImage: CVPixelBuffer?
    var depthSmoothImage: CVPixelBuffer?
    var colorImage: CVPixelBuffer?
    var confidenceImage: CVPixelBuffer?
    var confidenceSmoothImage: CVPixelBuffer?
    var cameraIntrinsics = simd_float3x3()
    var cameraResolution = CGSize()
}
