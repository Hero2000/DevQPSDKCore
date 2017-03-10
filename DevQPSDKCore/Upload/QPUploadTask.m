//
//  QPUploadTask.m
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 16/1/12.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "QPUploadTask.h"

@implementation QPUploadTask

- (CGFloat)progress {
    if (_uploadFinished) {
        return 1.0f;
    }else{
        if (_range.length == 0) {
            return 0.0f;
        }else{
            NSArray *array = [_range componentsSeparatedByString:@"-"];
            NSInteger from = [array[0] intValue];
            return (from + _thumbnailLength) / (CGFloat) (_videoLength + _thumbnailLength);
        }
    }
}
@end
