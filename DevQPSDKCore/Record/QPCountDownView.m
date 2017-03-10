//
//  QPCountDownView.m
//  qupai
//
//  Created by yly on 15/7/27.
//  Copyright (c) 2015年 duanqu. All rights reserved.
//

#import "QPCountDownView.h"
#import <AVFoundation/AVFoundation.h>

@implementation QPCountDownView{
    __weak UILabel *_label;
    AVAudioPlayer *_audioPlayer;
}

- (instancetype)initWithFrame:(CGRect)frame count:(NSInteger)count
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        _count = count;
        UILabel *label = [self createLabel];
        [self addSubview:label];
        _label = label;
    }
    return self;
}

- (UILabel *)createLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.text = [NSString stringWithFormat:@"%zd",_count];
    label.font = [UIFont boldSystemFontOfSize:150];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    return label;
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    NSLog(@"animation did start ");
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSLog(@"animation did stop");
    if (!flag) {
        [_delegate countDownViewAnimationFailed:self];
        return;
    }
    if (![_delegate countDownView:self showCount:_count]) {
        return;
    }
    _count -= 1;
    _label.text = [NSString stringWithFormat:@"%zd",_count];
    [self _startAnimation];
}

- (void)startAnimation
{
    [self _startAnimation];
    if (!_audioPlayer) {
        NSURL *url = [[QPBundle mainBundle] URLForResource:@"count-down-time" withExtension:@"mp3"];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [_audioPlayer play];
    }
}

- (void)_startAnimation
{
    CAAnimationGroup *group = [CAAnimationGroup animation];
    NSMutableArray *animations = [NSMutableArray array];
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = @(1);
        animation.toValue = @(0.1);
        animation.removedOnCompletion = NO;
        [animations addObject:animation];
    }
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.fromValue = @(0.1);
        animation.toValue = @(1.0);
        animation.removedOnCompletion = NO;
        animation.delegate = self;
        [animations addObject:animation];
    }
    group.animations = animations;
    group.duration = 1.0;
    group.delegate = self;
    [_label.layer addAnimation:group forKey:@"text_animation"];
    _label.layer.opacity = 0.1;
}

- (void)endAnimation
{
    [_audioPlayer pause];
    _audioPlayer = nil;
    [_label.layer removeAllAnimations];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self endAnimation];
}

@end
