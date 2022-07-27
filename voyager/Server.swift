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
    
    var filename = "test.jpg"
    var sequenceNo = 0
    var image: CVPixelBuffer
    var imageData: Data? {
        let ciImage = CIImage(cvPixelBuffer: image)
        let uiImage = UIImage(ciImage: ciImage)
        
        return uiImage.jpegData(compressionQuality: ServerImageUploadData.compressionQuality)
    }
}

class Server {
    
    let k = K()
    var serverURI: URL?
    var serverImageUploadURI: URL?
    
    init() {
        self.serverURI = URL(string: k.serverURI)
        self.serverImageUploadURI = serverURI?.appendingPathComponent(k.serverImageUploadEndpoint)
        if serverURI != nil, serverImageUploadURI != nil {
            print("server uri not constructed")
        }
    }
    
    func send(imgData: ServerImageUploadData) {
        
        let parameters: [String: Any] = [
            "filename": imgData.filename,
            "sequenceNo": imgData.sequenceNo
        ]
        
        _ = AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
            }
            
            multipartFormData.append(imgData.imageData!, withName: "img", fileName: imgData.filename, mimeType: "image/jpg")
                
        }, to: serverImageUploadURI!)
        
//        .responseDecodable(of: ImagePostResponseRawData.self) { response in
//            let diff = Double(mach_absolute_time() - tick) * Double(info.numer) / Double(info.denom)
//            print("response recieved: \(sequenceNo)")
//            print("\(diff / 1_000_000) milliseconds")
//
//            let response = ImagePostResponseData(response: response, timeInNano: diff)
//            self.postResponses.append(response)
//
//            if !async {
//                if sequenceNo < self.numTrial {
//                    self.postImageData(filename: filename, imgData: imgData, sequenceNo: sequenceNo + 1, async: false)
//                } else {
//                    self.showResult()
//                }
//            }
//        }
        
    }
}
