//
//  BCImageUtil.m
//  BlendingCamera
//
//  Created by 武田 祐一 on 12/09/30.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import "BCImageUtil.h"
#import "BCImageConverter.h"

@implementation BCImageUtil

+ (UIImage *)cutoffPartsRegion:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    cv::Mat lineSrc = [BCImageConverter cvMatFromUIImage:image];
    cv::Rect boundigBox = getBoundigBox(lineSrc);
    NSLog(@"offset = %d, %d", boundigBox.x, boundigBox.y);
    NSLog(@"size = %d, %d", boundigBox.width, boundigBox.height);

    cv::Mat dst = fillInside(lineSrc, boundigBox);
    
    return [BCImageConverter UIImageFromCVMat:dst];
}

cv::Rect getBoundigBox(cv::Mat src)
{
    cv::Point offset(src.rows, src.cols), cutoff(0, 0);
    int chanels = 4;
    for (int h = 0; h < src.rows; ++h) {
        unsigned char *buf = src.ptr<unsigned char>(h);
        for (int w = 0; w < src.cols; ++w) {
            unsigned char r = buf[w*chanels + 0];
            unsigned char g = buf[w*chanels + 1];
            unsigned char b = buf[w*chanels + 2];

            if (r+g+b > 0) {
                
                if (h < offset.y ) offset.y = h;
                if (w < offset.x ) offset.x = w;
                
                if (h > cutoff.y ) cutoff.y = h;
                if (w > cutoff.x ) cutoff.x = w;
                
            }

        }
    }

    cv::Rect ret;
    ret.x = offset.x;
    ret.y = offset.y;
    ret.width = cutoff.x - offset.x;
    ret.height = cutoff.y - offset.y;
    return ret;

}

cv::Mat fillInside(cv::Mat img, cv::Rect boundingBox)
{
    cv::Mat dst(boundingBox.size(), CV_8UC1);
    
    bool isInside;

    for (int h = 0; h < boundingBox.height; ++h) {
        unsigned char *dst_buf = dst.ptr<unsigned char>(h);
        unsigned char *src_buf = img.ptr<unsigned char>(h+boundingBox.y);
        
        for (int w = 0; w < boundingBox.width; ++w) {

            isInside = false;

            if (isInside) {
                dst_buf[w] = 255.0;
            }

            int src_w_idx = (w+boundingBox.x)*4;
            unsigned char srcSum = src_buf[src_w_idx+0] + src_buf[src_w_idx+1] + src_buf[src_w_idx+2];
            if (srcSum > 0) isInside = !isInside;
            
        }
        
    }
    
    return dst;
}

@end