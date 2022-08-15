//
//  DepthSaver.swift
//  voyager
//
//  Created by 지우석 on 2022/07/26.
//

import UIKit
import ARKit

/// 디버깅 목적으로, 현재 시점의 Depth 값을 float 배열로 가져와 클립보드에 저장하는 객체.
class DepthSaver {
    
    weak var arSession: ARSession!
    
    init(session: ARSession) {
        self.arSession = session
    }
    
    func saveDepthToCilpBoard() throws {
        
        guard let currentDepthMap = arSession.currentFrame?.smoothedSceneDepth?.depthMap else {
            throw NSError()
        }
        
        let depthAsArray = get2DimArrayFromDepthMap(depth: currentDepthMap)
        UIPasteboard.general.string = getStringFrom2DimArray(array: depthAsArray,
                                                             height: CVPixelBufferGetHeight(currentDepthMap),
                                                             width: CVPixelBufferGetWidth(currentDepthMap))
    }
    
    func get2DimArrayFromDepthMap(depth: CVPixelBuffer) -> [[Float32]] {
        let depthWidth = CVPixelBufferGetWidth(depth)
        let depthHeight = CVPixelBufferGetHeight(depth)
        
        CVPixelBufferLockBaseAddress(depth, CVPixelBufferLockFlags(rawValue: 0))
        
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depth), to: UnsafeMutablePointer<Float32>.self)
        
        var depthArray = [[Float32]]()
        
        for y in 0...depthHeight-1 {
            var distancesLine = [Float32]()
            for x in 0...depthWidth-1 {
                let distanceAtXYPoint = floatBuffer[y * depthWidth + x]
                distancesLine.append(distanceAtXYPoint)
                //                print("Depth in (\(x),\(y)): \(distanceAtXYPoint)")
            }
            depthArray.append(distancesLine)
        }
        
        return depthArray
    }
    // Read more at https://www.it-jim.com/blog/iphones-12-pro-lidar-how-to-get-and-interpret-data/
    
    // Auxiliary function to make String from depth map array
    func getStringFrom2DimArray(array: [[Float32]], height: Int, width: Int) -> String {
        var arrayStr: String = ""
        
        for y in 1...height-1 {
            var lineStr = ""
            
            for x in 1...width-1 {
                
                lineStr += String(array[y][x])
                if x != width-1 {
                    lineStr += ","
                }
            }
            lineStr += "\n"
            arrayStr += lineStr
        }
        return arrayStr
    }
    // Read more at https://www.it-jim.com/blog/iphones-12-pro-lidar-how-to-get-and-interpret-data/
    
}
