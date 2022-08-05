//
//  Server.swift
//  voyager
//
//  Created by 지우석 on 2022/07/27.
//

import Foundation
import CoreVideo
import Alamofire
import CoreImage
import UIKit

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

protocol ServerGuideDelegate: AnyObject {
    func alertGuide(guide: [ServerGuideResponseRawData])
}

class Server {
    
    let k = K()
    var serverURI: URL?
    var serverImageUploadURI: URL?
    var serverStartURI: URL?
    
    weak var guider: ServerGuideDelegate!
    
    init(viewController: ServerGuideDelegate) {
        self.guider = viewController
        
        self.serverURI = URL(string: k.serverURI)
        self.serverImageUploadURI = serverURI?.appendingPathComponent(k.serverImageUploadEndpoint)
        self.serverStartURI = serverURI?.appendingPathComponent(k.serverStartEndpoint)
        
        if serverURI != nil,
           serverImageUploadURI != nil,
           serverStartURI != nil {
            print("server uri constructed")
        } else {
            fatalError("server uri not constructed!")
        }
    }
    
    func start() {
        print("starting server")
        _ = AF.request(serverStartURI!, method: .put).response { [weak self] response in
            self?.guider.alertGuide(guide: ["starting guide!"])
        }
    }
    
    func stop() {}
    
    func send(imgData: ServerImageUploadData) {
        print("sending image to server")
        
        let parameters: [String: Any] = [
            "filename": imgData.filename,
            "sequenceNo": imgData.sequenceNo
        ]
        
        _ = AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
            }
            
            multipartFormData.append(imgData.imageData!, withName: "img", fileName: imgData.filename, mimeType: "image/jpg")
                
        }, to: serverImageUploadURI!).responseDecodable(of: [ServerGuideResponseRawData].self) { [weak self] response in
            print("response recieved: \(response)")
            if case .failure = response.result {
                print(response.debugDescription)
            } else {
                self?.guider.alertGuide(guide: try! response.result.get())
            }
        }
        
    }
}
