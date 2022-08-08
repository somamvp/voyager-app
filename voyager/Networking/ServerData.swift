//
//  ServerData.swift
//  voyager
//
//  Created by 지우석 on 2022/08/05.
//

import UIKit
import CoreImage

/// 서버에 이미지 업로드 request 시 사용하는 중간 객체.
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

/// 서버에 이미지 업로드 결과로 받는 response 객체. `sequenceNo`만 돌아오는 시나리오.
struct ServerImageResponseRawData: Decodable {
    let sequenceNo: Int
}

/// 서버에 이미지 업로드 결과로 받는 response 객체. Yolo 모델 결과가 JSON으로 돌아오는 시나리오.
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

/// 서버에 이미지 업로드 결과로 받는 response 객체. 안내 문장이 JSON Array of String으로 돌아오는 시나리오.
typealias ServerGuideResponseRawData = String
