//
//  depthGuider.swift
//  voyager
//
//  Created by 지우석 on 2022/08/10.
//

import Foundation

enum LandscapeGuide {
    case cliff(distance: Float)
    case wall(distance: Float)
}

class DepthGuider {
    let columnIntercept = 100
    
    func f(depthImage: CVPixelBuffer) {
        var depthColumn = getColumnInterceptFromDepthMap(depth: depthImage, column: columnIntercept)
    }
    
    func getColumnInterceptFromDepthMap(depth: CVPixelBuffer, column x: Int) -> [Float32] {
        let depthWidth = CVPixelBufferGetWidth(depth)
        let depthHeight = CVPixelBufferGetHeight(depth)
        guard 0...depthWidth ~= x else {
            fatalError("column value not valid integer up to width \(depthWidth)!")
        }
        
        CVPixelBufferLockBaseAddress(depth, CVPixelBufferLockFlags(rawValue: 0))
        
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depth),to: UnsafeMutablePointer<Float32>.self)
        
        var depthArray = [Float32]()
        
        for y in 0...depthHeight-1 {
            let distanceAtXYPoint = floatBuffer[y * depthWidth + x]
            depthArray.append(distanceAtXYPoint)
        }
        
        return depthArray
    }
    
    func detectLandscape(depthColumn: [Float32]) {
        let diff = getDiffFromReference(depthColumn: depthColumn)
        
        let patience = 5
        
        var i = 255
        var isDone = false
        while i > 92 {
            
            i -= 1
            
            if (diff[i] > DepthK.refDeviation[i]) {
                isDone = true
                
                for di in 1...1+patience {
                    if (diff[i - di] <= DepthK.refDeviation[i - di]) {
                        i -= di
                        isDone = false
                        break
                    }
                }
            }
            else if (diff[i] < -DepthK.refDeviation[i]) {
                isDone = true
                
                for di in 1...1+patience {
                    if (diff[i - di] >= -DepthK.refDeviation[i - di]) {
                        i -= di
                        isDone = false
                        break
                    }
                    
                }
            }
            
            if isDone {
                
                if diff[i] > 0 {
                    print("추락지형 발견! \(i)")
                } else if diff[i] < 0 {
                    print("장애물 발견! \(i)")
                }
                
                break
            }
            
        }
    }
    
    func getDiffFromReference(depthColumn: [Float32]) -> [Float32] {
        var columnCalibrated = subtractTailOffset(arr: depthColumn)
        
        for idx in 0..<columnCalibrated.count {
            columnCalibrated[idx] -= DepthK.depthReference[idx]
        }
        
        return columnCalibrated
    }
    
    func subtractTailOffset(arr: [Float32]) -> [Float32] {
        let tailValue = arr[arr.count - 1]
        var offsetSubtracted = [Float32]()
        
        for idx in 0..<arr.count {
            offsetSubtracted.append( arr[idx] - tailValue )
        }
        return offsetSubtracted
    }
    
}
