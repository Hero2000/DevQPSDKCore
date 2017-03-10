//
//  QupaiSDK-Private.h
//  QupaiSDK
//
//  Created by yly on 15/6/29.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

@class QPVideo;


typedef NS_ENUM(NSInteger, QPVideoRatio) {
    QPVideoRatio9To16,
    QPVideoRatio3To4,
    QPVideoRatio1To1,
    QPVideoRatio4To3,
    QPVideoRatio16To9,
};

@interface QupaiSDK()

@property (nonatomic, assign) CGFloat  maxDuration;     /* 允许拍摄的最大时长 */
@property (nonatomic, assign) CGFloat  minDuration;     /* 允许拍摄的最小时长 */
@property (nonatomic, assign) CGFloat  bitRate;         /* 视频码率， bits per second */
@property (nonatomic, weak) QPVideo    *recordVideo;
@property (nonatomic, assign) CGSize   videoSize;       /* 视频大小 */

- (void)compelete:(NSString *)path thumbnailPath:(NSString *)thumbnailPath;

- (NSString *)appName;
    
// 当前视频分辨率最接近的分辨率比例
- (QPVideoRatio)videoRatio;

@end
