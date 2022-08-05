//
//  Server.swift
//  voyager
//
//  Created by 지우석 on 2022/07/27.
//

import Alamofire

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
    
    func getMultipartAppender(imgData: ServerImageUploadData) -> ((MultipartFormData) -> Void) {
        return { data in
            data.append(imgData.filename.data(using: .utf8)!, withName: "filename", mimeType: "text/plain")
            data.append("\(imgData.sequenceNo)".data(using: .utf8)!, withName: "sequenceNo", mimeType: "text/plain")
            data.append(imgData.imageData!, withName: "img", fileName: imgData.filename, mimeType: "image/jpg")
        }
    }
    
    func send(imgData: ServerImageUploadData) {
        print("sending image to server")
        
        _ = AF.upload(
            multipartFormData: getMultipartAppender(imgData: imgData),
            to: serverImageUploadURI!
        ).responseDecodable(of: [ServerGuideResponseRawData].self) { [weak self] response in
            print("response recieved: \(response)")
            if case .failure = response.result {
                print(response.debugDescription)
            } else {
                self?.guider.alertGuide(guide: try! response.result.get())
            }
        }
        
    }
}
