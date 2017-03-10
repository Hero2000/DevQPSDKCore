//
//  QPVideoInfo.h
//  PaasDemo
//
//  Created by zhangwx on 16/1/4.
//  Copyright © 2016年 zhangwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


@interface QPVideoInfo : QPJSONModel
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *videoMD5;
@property (nonatomic, assign) NSUInteger videoLength;
@property (nonatomic, assign) NSUInteger thumbnailLength;
@property (nonatomic, assign) NSUInteger rangeFrom;
@property (nonatomic, assign) NSUInteger rangeTo;
@property (nonatomic, assign) BOOL uploadFinished;

+ (instancetype)videoInfoWithFilePath:(NSString *)filePath;

+ (NSString*)fileMD5:(NSString*)path;
@end
