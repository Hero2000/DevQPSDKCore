//
//  QPSave.h
//  QupaiSDK
//
//  Created by yly on 15/6/29.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QPSave : QPJSONModel

+ (instancetype)shared;

@property (nonatomic, assign) BOOL recordGuide;
@property (nonatomic, assign) BOOL skinOpenGuide;
@property (nonatomic, assign) BOOL skinCloseGuide;

@property (nonatomic, assign) BOOL importDurationGuide;
@property (nonatomic, assign) BOOL cutDragGuide;

@property (nonatomic, assign) BOOL skinTipGuide;
@property (nonatomic, assign) BOOL backDeleteTipGuide;
@property (nonatomic, assign) BOOL backDeleteTrashTipGuide;
@property (nonatomic, assign) BOOL recordImportTipGuide;
@property (nonatomic, assign) BOOL sdkLaunched;  // sdk是否被启动过

@property (nonatomic, strong) NSString *draftVideoPackName;
@property (nonatomic, assign) NSInteger countDownRecordTimes;// 倒计时点击次数
- (void)save;

@end
