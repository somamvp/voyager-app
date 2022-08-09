//
//  OpenCV.h
//  voyager
//
//  Created by 지우석 on 2022/08/08.
//

#import <Foundation/Foundation.h>
#import "OpenCV.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/opencv.hpp>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCV : NSObject

+ (UIImage *)toGray:(UIImage *)image;

+ (double)max:(cv::Mat)M;

+ (double)min:(cv::Mat)M;

@end

NS_ASSUME_NONNULL_END
