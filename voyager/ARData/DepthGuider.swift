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
    case normal
}

class DepthGuider {
    
    let columnIntercept = 100
    let depthImageRows = 255
    let scanColumnFromPixel = 92
    
    func detectLandscape(depthImage: CVPixelBuffer) -> LandscapeGuide {
        let depthColumnReversed = getColumnInterceptFromDepthMap(depth: depthImage, column: columnIntercept)
        
        print(depthColumnReversed)
        
        let diffs = getDiffFromReference(depthColumn: depthColumnReversed)
        
        let deviationResultTuple = findDeviationFromZero(arr: diffs, from: 0, to: diffs.count - scanColumnFromPixel, deviation: DepthK.refDeviation)
        
        let resultPixel = depthImageRows - deviationResultTuple.index
        
        switch deviationResultTuple.sign {
        case 1 :
            return LandscapeGuide.cliff(distance: pixelToMeter(pixel: resultPixel))
        case -1:
            return LandscapeGuide.wall(distance: pixelToMeter(pixel: resultPixel))
        default:
            return LandscapeGuide.normal
        }
    }
    
    func pixelToMeter(pixel: Int) -> Float {
        let x = Double(pixel)
        let meter = 0.0001691178 * x * x - 0.0764576533 * x + 9.5615110899
        return Float(meter)
    }
    
    func getColumnInterceptFromDepthMap(depth: CVPixelBuffer, column: Int, bottomUp: Bool = true) -> [Float] {
        
        // depth image is rotated to left! changing image direction to real world direction.
        let depthWidth = CVPixelBufferGetHeight(depth)
        let depthHeight = CVPixelBufferGetWidth(depth)
        let x = depthWidth - 1 - column
        
        guard 0...depthWidth ~= x else {
            fatalError("column value not valid integer up to width \(depthWidth)!")
        }
        
        CVPixelBufferLockBaseAddress(depth, CVPixelBufferLockFlags(rawValue: 0))
        
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depth),to: UnsafeMutablePointer<Float>.self)
        
        var depthArray = [Float]()
        
        let columnScanRange = bottomUp ? stride(from: depthHeight-1, to: 0, by: -1) : stride(from: 0, to: depthHeight-1, by: 1)
        for y in columnScanRange {
            let distanceAtXYPoint = floatBuffer[x * depthHeight + y]
            depthArray.append(distanceAtXYPoint)
        }
        
        return depthArray
    }
    
    func getDiffFromReference(depthColumn: [Float]) -> [Float] {
        var columnCalibrated = subtractHeadOffset(arr: depthColumn)
        
        for idx in 0..<columnCalibrated.count {
            columnCalibrated[idx] -= DepthK.depthReference[idx]
        }
        
        return columnCalibrated
    }
    
    func subtractHeadOffset(arr: [Float]) -> [Float] {
        let headValue = arr[0]
        var offsetSubtracted = [Float]()
        
        for idx in 0..<arr.count {
            offsetSubtracted.append( arr[idx] - headValue )
        }
        return offsetSubtracted
    }
    
    func findDeviationFromZero(arr: [Float], from: Int, to: Int, deviation: [Float], patience: Int = 5) -> (sign: Int, index: Int) {
        
        var idx = from
        var isDone = false
        
        while idx < to {
            idx += 1
            
            if arr[idx] > deviation[idx] {
                isDone = true
                
                for searchIdx in 1...1+patience {
                    if !(arr[idx + searchIdx] > deviation[idx + searchIdx]) {
                        idx += searchIdx
                        isDone = false
                        break
                    }
                }
            }
            
            else if (arr[idx] < -deviation[idx]) {
                isDone = true
                
                for searchIdx in 1...1+patience {
                    if !(arr[idx + searchIdx] < -deviation[idx + searchIdx]) {
                        idx += searchIdx
                        isDone = false
                        break
                    }
                }
            }
            
            if isDone {
                
                if arr[idx] > 0 {
                    return (sign: 1, index: idx)
                } else if arr[idx] < 0 {
                    return (sign: -1, index: idx)
                }
                
                break
            }
        }
        
        return (sign: 0, index: 0)
    }
    
    
}
