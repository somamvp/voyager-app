//
//  ServerData.swift
//  voyager
//
//  Created by 지우석 on 2022/08/05.
//

import UIKit
import CoreImage

struct ServerImageUploadData {
    static var compressionQuality = 0.5
    static var targetSize = CGSize(width: 160, height: 320)
    
    var filename = "test.jpg"
    var sequenceNo = 0
    var image: CVPixelBuffer
    var imageData: Data? {
        let ciImage = CIImage(cvPixelBuffer: image).oriented(.right)
        let scaledUIImage = UIImage(ciImage: ciImage).scalePreservingAspectRatio(targetSize: ServerImageUploadData.targetSize)
        
        return scaledUIImage.jpegData(compressionQuality: ServerImageUploadData.compressionQuality)
    }
}

struct ServerImageResponseRawData: Decodable {
    let sequenceNo: Int
}

struct ServerYoloResponseRawData: Decodable {
    let xmin: Double
    let xmax: Double
    let ymin: Double
    let ymax: Double
    
    let classId: Int
    let className: String
    
    enum CodingKeys: String, CodingKey {
        case xmin
        case xmax
        case ymin
        case ymax
        
        case classId = "class"
        case className = "name"
    }
}

typealias ServerGuideResponseRawData = String
