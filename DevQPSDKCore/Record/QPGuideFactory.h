//
//  QPGuideFactory.h
//  QupaiSDK
//
//  Created by lyle on 14-3-25.
//  Copyright (c) 2014年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QPGuideFactory : NSObject

+ (UIView *)createRecordDown;
+ (UIView *)createRecordUp;
+ (UIView *)createRecordUpPause;
+ (UIView *)createRecordTime;
+ (UIView *)createRecordChangeScene;
+ (UIView *)createRecordFinish;

+(UIView *)createNoticeDeleteGuide;
+(UIView *)createDeleteGuide;
+(UIView *)createImportGuide;
+(UIView *)createSaveGuide;

+(UIView *)createBeautyGuide;

+ (UIView *)createRecordAudioDown;

+ (UIView *)createDragVideo;
+ (UIView *)createDragTimer;

+ (UIView *)createRotateShoot;

+(UIView *)createPasterRotate;
@end
