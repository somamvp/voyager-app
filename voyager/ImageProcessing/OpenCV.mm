//
//  OpenCV.m
//  voyager
//
//  Created by 지우석 on 2022/08/08.
//

#import "OpenCV.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/opencv.hpp>

@implementation OpenCV

+ (double) max: (cv::Mat)M {
    // compute the sum of positive matrix elements, optimized variant
    double max=0;
    int cols = M.cols, rows = M.rows;
    for(int i = 0; i < rows; i++)
    {
        const double* Mi = M.ptr<double>(i);
        for(int j = 0; j < cols; j++)
            max = std::max(Mi[j], max);
    }
    return max;
}

+ (double) min: (cv::Mat)M {
    // compute the sum of positive matrix elements, optimized variant
    double min=0;
    int cols = M.cols, rows = M.rows;
    for(int i = 0; i < rows; i++)
    {
        const double* Mi = M.ptr<double>(i);
        for(int j = 0; j < cols; j++)
            min = std::min(Mi[j], min);
    }
    return min;
}

+ (UIImage *) toGray: (UIImage *)image {
    //Transform UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);

    //If the image was alreay grayscale, return it
    if (imageMat.channels() == 1)
        return image;

    NSLog(@"image size: %@", imageMat.size);
    NSLog(@"image min: %f", [OpenCV min:imageMat]);
    NSLog(@"image max: %f", [OpenCV max:imageMat]);
 
    //Transform the cv::mat color image to gray
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, cv::COLOR_BGR2GRAY);

    //Transform grayMat to UIImage and return
    return MatToUIImage(grayMat);
}



@end
