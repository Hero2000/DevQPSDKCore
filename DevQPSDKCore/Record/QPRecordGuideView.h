//
//  GuideView.h
//  duanqu2
//
//  Created by lyle on 13-5-31.
//  Copyright (c) 2013年 duanqu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuideViewDelegate;

@interface QPRecordGuideView : UIView

- (void)recordStart;
- (void)recordDoing;
- (void)recordPause;
- (void)recordFocus;
- (void)recordFinish;
- (void)recordEffect;
- (void)recordTimeUpdate:(float)time;
- (void)jumpToTime:(CGFloat)time;

@end