//
//  QUFocusView.m
//  QUPAI3_RECORD
//
//  Created by yly on 14/10/23.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import "QPFocusView.h"
#import "QPLightProgress.h"

@interface QPFocusView()
{
    UIImageView *_imageViewFocus;
    QPLightProgress *_lightProgress;
    NSTimer *_timer;
}

@end

@implementation QPFocusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleToFill;
        _imageViewFocus = [[UIImageView alloc] initWithImage:[QPImage imageNamed:@"record_focus"]];//record_focus_big
        [self addSubview:_imageViewFocus];
        
        CGRect rectLight = CGRectMake(0, 0, 30, 140);
        _lightProgress = [[QPLightProgress alloc] initWithFrame:rectLight];
        _lightProgress.progress = 0.5;
        [self addSubview:_lightProgress];
        
        self.frame = _imageViewFocus.frame;
    }
    return self;
}

- (void)dealloc
{
    [self.layer removeAllAnimations];
}

- (void)setAutoFocus:(BOOL)autoFocus
{
    _autoFocus = autoFocus;
//    _lightProgress.hidden = autoFocus;//自动对焦不现实
    _lightProgress.hidden = NO;//一直显示
}

- (void)refreshPosition
{
    CGFloat x = -22;
    if (CGRectGetMaxX(self.frame) < ScreenWidth - 60) {
        x = CGRectGetWidth(self.bounds) + 22;
    }
    _lightProgress.center = CGPointMake(x, CGRectGetHeight(self.bounds)/2.0);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(delayFirst:) withObject:nil afterDelay:1.5];
}

- (void)changeExposureValue:(CGFloat)value
{
    CGFloat v = _lightProgress.progress + value;
    if (v >= 0 || v <= 1.0) {
        _lightProgress.progress = value;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(delayFirst:) withObject:nil afterDelay:1.5];
}

- (void)delayFirst:(id)obj
{
    self.alpha = 0.7;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(delaySecond:) withObject:nil afterDelay:1.0];
}

- (void)delaySecond:(id)obj
{
    if (self.alpha == 0) {
        return;
    }
    [self.layer removeAllAnimations];
    self.alpha = 0.7;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:nil];
}
#pragma mark -

- (void)startAnimation
{
//    NSLog(@"focus start animation .....");
    [self refreshPosition];
    [self.layer removeAllAnimations];
    
    self.transform = CGAffineTransformMakeScale(1.75f, 1.75f); //144  252
    self.alpha = 0.5;
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
                _imageViewFocus.alpha = 0.7;
            } completion:nil];
        }
    }];
}

- (void)stopAnimation
{
//    NSLog(@"focus stop animation *******");
//    if (self.alpha == 0) {
//        return;
//    }
//    [self.layer removeAllAnimations];
//    self.alpha = 0.7;
//    [UIView animateWithDuration:0.2 animations:^{
//        self.alpha = 0;
//    } completion:nil];
}

@end
