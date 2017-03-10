//
//  QUMediaPack.h
//  QPSDKCore
//
//  Created by yly on 16/4/15.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QPMediaPackAudioMixType) {
    QPMediaPackAudioMixTypeOrigin,
    QPMediaPackAudioMixTypeMVMusic,
    QPMediaPackAudioMixTypeMusic
};

@interface QPMediaPack : NSObject

// 视频路径
@property (nonatomic, copy) NSString *videoPath;
// 音乐路径
@property (nonatomic, copy) NSString *musicPath;
// 混合音量
@property (nonatomic, assign) CGFloat mixVolume;
// 视频大小
@property (nonatomic, assign) CGSize videoSize;
// 分段视频路径数组
@property (nonatomic, strong) NSMutableArray *videoPathArray;
// 分段视频 视频方向
@property (nonatomic, strong) NSMutableArray *rotateArray;

// effect config.json full path
@property (nonatomic, copy) NSString *effectPath;

// 保存的视频路径
@property (nonatomic, copy) NSString *savePath;
// 保存的视频的画质级别
@property (nonatomic, copy) NSString *saveProfileLevel;
// 保存的视频大小
@property (nonatomic, assign) CGSize saveSize;
// 保存的视频比特率
@property (nonatomic, assign) NSUInteger saveBitRate;
// 保存的视频水印图片
@property (nonatomic, strong) UIImage* saveWatermarkImage;

// 音效路径
@property (nonatomic, copy) NSString *soundPath;

@property (nonatomic, copy) NSArray *soundComposition;

@property (nonatomic, assign) QPMediaPackAudioMixType audioMixType;

- (CGSize)outputSize;

@end
