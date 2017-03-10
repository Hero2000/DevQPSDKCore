//
//  QPRecordViewController.h
//  QupaiSDK
//
//  Created by yly on 15/6/16.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPBaseViewController.h"
//#import "QPPickerPreviewViewController.h"
//#import "QPRenderer.h"
//#import "QPRecorder.h"

@interface QPRecordViewController : QPBaseViewController<QPRecordDelegate>

@property (nonatomic, assign) BOOL videoIsDraft;
@property (nonatomic, assign) BOOL videoNeedToEffectView;

@end
