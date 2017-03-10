//
//  QPCutCenterProgressView.h
//  QupaiSDK
//
//  Created by yly on 15/6/23.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QPCutCenterProgressView : UIView

@property (nonatomic, strong) UIColor *colorNomal;
@property (nonatomic, strong) UIColor *colorSelect;
@property (nonatomic, strong) UIColor *colorBg;

@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;

- (void)updateProgress:(CGFloat)progress;

@end
