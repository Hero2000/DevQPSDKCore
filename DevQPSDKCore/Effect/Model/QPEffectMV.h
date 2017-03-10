//
//  QPEffectMV.h
//  DevQPSDKCore
//
//  Created by Worthy on 16/8/29.
//  Copyright © 2016年 LYZ. All rights reserved.
//

#import "QPEffect.h"
#import "QPEffectMVAspect.h"
@class QUMVTemplate;


typedef NS_ENUM(NSInteger, QPEffectMVRatio) {
    QPEffectMVRatio9To16,
    QPEffectMVRatio3To4,
    QPEffectMVRatio1To1,
    QPEffectMVRatio4To3,
    QPEffectMVRatio16To9,
};

@interface QPEffectMV : QPEffect

@property (nonatomic, strong) QUMVTemplate *mvTemplate;
//@property (nonatomic, strong) NSString *mvPath;
//@property (nonatomic, strong) NSString *mvUrl;  // preview mp4 url

@property (nonatomic, strong) NSString *previewMp4;
@property (nonatomic, strong) NSString *previewPic;
//@property (nonatomic, assign) QPEffectMVRatio mvRatio;
@property (nonatomic, strong) NSArray<QPEffectMVAspect> *aspectList;
    
// 特定长宽比的资源路径
- (NSString *)resourceLocalRatioPathWithRatio:(QPEffectMVRatio)ratio;
// 图标资源路径
- (NSString *)resourceLocalIconPath;

@end
