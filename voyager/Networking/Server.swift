//
//  Server.swift
//  voyager
//
//  Created by 지우석 on 2022/07/27.
//

import Alamofire

protocol ServerGuideDelegate: AnyObject {
    func alertGuide(guide: [ServerGuideResponseRawData])
    
    func requestStartGuiding()
    func startGuiding()
    func requestStopGuiding()
    func stopGuiding()
}

/// 백엔드 API 서버와 통신하는 역할을 담당하는 객체.
/// `start()` 를 통해 서버에 안내 시작 신호를 보내고, `stop()` 통해 안내 중지.
/// `send()`를 통해 데이터를 보내고 수신 결과로 콜백 호출.
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
        _ = AF.request(serverStartURI!, method: .get).response { [weak self] response in
            if case .failure = response.result {
                print(response.debugDescription)
            } else {
                self?.guider.startGuiding()
            }
        }
    }
    
    func stop() {
        self.guider.stopGuiding()
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
    
    func getMultipartAppender(imgData: ServerImageUploadData) -> ((MultipartFormData) -> Void) {
        return { data in
            data.append(imgData.filename.data(using: .utf8)!, withName: "filename", mimeType: "text/plain")
            data.append("\(imgData.sequenceNo)".data(using: .utf8)!, withName: "sequenceNo", mimeType: "text/plain")
            data.append(imgData.imageData!, withName: "img", fileName: imgData.filename, mimeType: "image/jpg")
        }
    }
}
