//
//  PointProgress.h
//  Qupai_1.5_dev
//
//  Created by lyle on 13-8-29.
//  Copyright (c) 2013年 duanqu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QPVideoPoint.h"

@class QPVideo;

@interface QPPointProgress : UIView

@property (nonatomic, strong) QPVideo *video;
@property (nonatomic, assign) BOOL showNoticePoint;
@property (nonatomic, assign) BOOL showBlink;
@property (nonatomic, assign) BOOL showCursor;
@property (nonatomic, assign) NSInteger times;
@property (nonatomic, strong) UIColor *colorNomal;
@property (nonatomic, strong) UIColor *colorSelect;
@property (nonatomic, strong) UIColor *colorBg;
@property (nonatomic, strong) UIColor *colorNotice;

- (void)updateProgress:(CGFloat)progress;

@end
