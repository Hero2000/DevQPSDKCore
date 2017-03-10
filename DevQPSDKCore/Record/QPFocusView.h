//
//  QUFocusView.h
//  QUPAI3_RECORD
//
//  Created by yly on 14/10/23.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QPFocusView : UIView

- (void)startAnimation;
- (void)stopAnimation;

- (void)refreshPosition;
- (void)changeExposureValue:(CGFloat)value;

@property (nonatomic, assign) BOOL autoFocus;

@end
