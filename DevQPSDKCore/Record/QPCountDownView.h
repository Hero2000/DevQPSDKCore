//
//  QPCountDownView.h
//  qupai
//
//  Created by yly on 15/7/27.
//  Copyright (c) 2015年 duanqu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QPCountDownViewDelegate;

@interface QPCountDownView : UIView

@property (nonatomic, assign, readonly) NSInteger count;
@property (nonatomic, weak) id<QPCountDownViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame count:(NSInteger)count;
- (void)startAnimation;
- (void)endAnimation;

@end

@protocol QPCountDownViewDelegate <NSObject>

- (BOOL)countDownView:(QPCountDownView *)countDownView showCount:(NSInteger)showCount;
- (void)countDownViewAnimationFailed:(QPCountDownView *)countDownView;

@end