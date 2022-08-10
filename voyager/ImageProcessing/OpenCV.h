//
//  OpenCV.h
//  voyager
//
//  Created by 지우석 on 2022/08/08.
//

#import <Foundation/Foundation.h>
#import "OpenCV.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCV : NSObject

+ (UIImage *)toGray:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
