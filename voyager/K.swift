//
//  K.swift
//  voyager
//
//  Created by 지우석 on 2022/07/27.
//

import Foundation

struct K {
    
    var serverURI: String
    var serverImageUploadEndpoint: String
}

extension K {
    
    init() {
        guard let url = Bundle.main.url(forResource: "secrets", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: url) else {
            fatalError("secrets.plist not found!")
        }
        
        // read
        if let serverURI = dictionary["server-uri"] as? String,
           let serverImageUploadEndpoint = dictionary["image-post-endpoint"] as? String {
            
            self.serverURI = serverURI
            self.serverImageUploadEndpoint = serverImageUploadEndpoint
            
        } else {
            fatalError("secrets.plist not containing server uri and endpoint!")
        }
    }
    
}
