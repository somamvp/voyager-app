//
//  K.swift
//  voyager
//
//  Created by 지우석 on 2022/07/27.
//

import Foundation

struct K {
    
    static var startButtonText = "Start!"
    static var stopButtonText = "Stop!"
    
    var serverURI: String
    var serverImageUploadEndpoint: String
    var serverStartEndpoint: String
}

extension K {
    
    init() {
        guard let url = Bundle.main.url(forResource: "secrets", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: url) else {
            fatalError("secrets.plist not found!")
        }
        
        // read
        if let serverURI = dictionary["server-uri"] as? String,
           let serverImageUploadEndpoint = dictionary["image-post-endpoint"] as? String,
           let serverStartEndpoint = dictionary["start-endpoint"] as? String {
            
            self.serverURI = serverURI
            self.serverImageUploadEndpoint = serverImageUploadEndpoint
            self.serverStartEndpoint = serverStartEndpoint
            
        } else {
            fatalError("secrets.plist not containing server uri and endpoints!")
        }
    }
    
}
