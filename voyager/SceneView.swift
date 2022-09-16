//
//  SceneView.swift
//  voyager
//
//  Created by 지우석 on 2022/09/16.
//

import UIKit
import AVFoundation
import ARKit

protocol SceneView: UIView {}

extension ARSCNView: SceneView {}

class AVSCNView: UIView, SceneView {
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
