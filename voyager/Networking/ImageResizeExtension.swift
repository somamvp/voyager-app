//
//  ImageResizeExtension.swift
//  voyager
//
//  Created by 지우석 on 2022/08/03.
//

// from https://www.advancedswift.com/resize-uiimage-no-stretching-swift/

import UIKit

/// `UIImage` 객체에 resizing 기능을 부여하는 extension.
extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize,
            format: rendererFormat
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
    func jpegDataWithScalePreservingAspectRatio(compressionQuality: Double, targetSize: CGSize) -> Data {
        
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize,
            format: rendererFormat
        )
        
        let jpegData = renderer.jpegData(withCompressionQuality: CGFloat(compressionQuality)) { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return jpegData
    }
}
