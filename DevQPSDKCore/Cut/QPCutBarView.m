//
//  QPCutBarView.m
//  QupaiSDK
//
//  Created by lyle on 14-3-18.
//  Copyright (c) 2014年 lyle. All rights reserved.
//

#import "QPCutBarView.h"
#import "QPCutInfo.h"

static NSArray *ObservabKeys = nil;
static NSString *const CutInfoStartTimeKeyPath = @"_cutInfo.startTime";
static NSString *const CutInfoEndTimeKeyPath = @"_cutInfo.endTime";
static NSString *const CutInfoOffsetTimeKeyPath = @"_cutInfo.offsetTime";
static NSString *const CutInfoPlayTimeKeyPath = @"_cutInfo.playTime";

static const NSInteger CutBarWidth = 28;
static const NSInteger CutBarUpNeedleWidth = 3;

static const CGFloat CutBarImageWidth = 28;
static const CGFloat CutBarImageHeight = 75.5;
static const CGFloat ThumbnailAndProgressHeight = -43;
#define CutScreenWidth  ScreenWidth

@implementation QPCutBarView
{
    UIImageView *_imageViewLeft;
    UIImageView *_imageViewRight;
    UIImageView *_imageViewMiddle;
    
    UIView *_viewMaskLeft;
    UIView *_viewMaskRight;
    
    UIImageView *_selectImageView;
    CGColorRef _backColorRef;
    
    QPCutInfo *_cutInfo;
}

- (id)initWithFrame:(CGRect)frame cutInfo:(QPCutInfo *)cutInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        _cutInfo = cutInfo;
        
        _viewMaskLeft = [[UIView alloc] initWithFrame:CGRectMake(0, ThumbnailAndProgressHeight, 1, 46)];
        _viewMaskLeft.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self addSubview:_viewMaskLeft];
        
        _viewMaskRight = [[UIView alloc] initWithFrame:CGRectMake(0, ThumbnailAndProgressHeight, 1, 46)];
        _viewMaskRight.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self addSubview:_viewMaskRight];
        
        _imageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, ThumbnailAndProgressHeight - 2, CutBarImageWidth, CutBarImageHeight)];
        _imageViewLeft.image = [QPImage imageNamed:@"cut_bar_left"];
        [self addSubview:_imageViewLeft];
        
        _imageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(20, ThumbnailAndProgressHeight -2, CutBarImageWidth, CutBarImageHeight)];
        _imageViewRight.image = [QPImage imageNamed:@"cut_bar_right"];
        [self addSubview:_imageViewRight];
        
        _imageViewMiddle = [[UIImageView alloc] initWithFrame:CGRectMake(0, ThumbnailAndProgressHeight + 3, 6, 40)];
        _imageViewMiddle.image = [QPImage imageNamed:@"cut_bar_progress"];
        [self addSubview:_imageViewMiddle];
        
        [self addStausObserver];
        [self refreshViewLayout];
        [self refreshImageViewMiddle];
    }
    return self;
}

- (void)refreshViewLayout
{
    CGFloat left = _cutInfo.startTime/_cutInfo.cutMaxDuration * CutScreenWidth;
    CGFloat rigth = _cutInfo.endTime/_cutInfo.cutMaxDuration * CutScreenWidth;
    
    CGRect f = _viewMaskLeft.frame;
    f.size.width = left;
    _viewMaskLeft.frame = f;
    
    f = _imageViewLeft.frame;
    f.origin.x = left;
    _imageViewLeft.frame = f;
    
    CGFloat du = _cutInfo.videoDuration/_cutInfo.cutMaxDuration * CutScreenWidth;
    
    f = _viewMaskRight.frame;
    f.size.width = du - rigth;
    f.origin.x = rigth;
    _viewMaskRight.frame = f;
    
    f = _imageViewRight.frame;
    f.origin.x = rigth - CutBarWidth;
    _imageViewRight.frame = f;
}

- (void)refreshImageViewMiddle
{
    CGFloat middle = (_cutInfo.playTime - _cutInfo.offsetTime)/_cutInfo.cutMaxDuration * CutScreenWidth;
    CGFloat left = _cutInfo.startTime/_cutInfo.cutMaxDuration * CutScreenWidth;
    CGFloat rigth = _cutInfo.endTime/_cutInfo.cutMaxDuration * CutScreenWidth;
    
    if ((left + CutBarUpNeedleWidth < middle && middle < rigth - CutBarUpNeedleWidth) || middle < 0) {
        CGRect f = _imageViewMiddle.frame;
        f.origin.x = middle - CGRectGetWidth(f)/2;
        _imageViewMiddle.frame = f;
    }
}

- (void)dealloc
{
    [self removeStatusObserver];
}
#pragma mark - KVO

- (void)addStausObserver
{
    if (ObservabKeys == nil) {
        ObservabKeys = @[CutInfoStartTimeKeyPath, CutInfoEndTimeKeyPath,
                         CutInfoOffsetTimeKeyPath, CutInfoPlayTimeKeyPath];
    }
    for (NSString *keyPath in ObservabKeys) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)removeStatusObserver
{
    for (NSString *keyPath in ObservabKeys) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![ObservabKeys containsObject:keyPath]) {
        [super observeValueForKeyPath:keyPath ofObject:self change:change context:context];
        return;
    }else if([CutInfoPlayTimeKeyPath isEqualToString:keyPath]){
        [self refreshImageViewMiddle];
    }else{
        [self refreshViewLayout];
    }
}

#pragma mark - touch

- (CGRect)adjustLeftImageViewRespondRect:(CGRect)leftRect withExtendWidth:(CGFloat)extendWidth
{
    CGRect rcAdjust = leftRect;
    rcAdjust.origin.x -= CutScreenWidth;
    rcAdjust.size.width += (CutScreenWidth+extendWidth);
    rcAdjust.size.height += 30;
    return rcAdjust;
}

- (CGRect)adjustRightImageViewRespondRect:(CGRect)rightRect withExtendWidth:(CGFloat)extendWidth
{
    CGRect rcAdjust = rightRect;
    rcAdjust.origin.x -= extendWidth;
    rcAdjust.size.width += CutScreenWidth;
    rcAdjust.size.height += 30;
    return rcAdjust;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CGRect adjustLeftRespondRect = _imageViewLeft.frame;
    CGRect adjustRightRespondRect = _imageViewRight.frame;
    CGFloat intervalWidth = adjustRightRespondRect.origin.x - adjustLeftRespondRect.origin.x;
    if (intervalWidth > 0) {
        intervalWidth = intervalWidth/2.0;
    } else {
        intervalWidth = 10;
    }
    adjustLeftRespondRect = [self adjustLeftImageViewRespondRect:_imageViewLeft.frame withExtendWidth:intervalWidth];
    adjustRightRespondRect = [self adjustRightImageViewRespondRect:_imageViewRight.frame withExtendWidth:intervalWidth];

    NSLog(@"%@", NSStringFromCGPoint(point));
    if (CGRectContainsPoint(adjustLeftRespondRect, point)) {
        _selectImageView = _imageViewLeft;
    }else if(CGRectContainsPoint(adjustRightRespondRect, point)){
        _selectImageView = _imageViewRight;
    }else{
        _selectImageView = nil;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_selectImageView) {
        UITouch *touch = (UITouch *)[touches anyObject];
        CGPoint lp = [touch locationInView:self];
        CGPoint pp = [touch previousLocationInView:self];

        CGFloat offset = lp.x - pp.x;
        CGFloat time = offset/CutScreenWidth * _cutInfo.cutMaxDuration;
        if (_selectImageView == _imageViewLeft) {
            CGFloat left = _cutInfo.startTime + time;
            if (0 < left && left < _cutInfo.endTime - _cutInfo.cutMinDuration) {
                _cutInfo.startTime = left;
            }
        }else if(_selectImageView == _imageViewRight){
            CGFloat right = _cutInfo.endTime + time;
            if (_cutInfo.startTime + _cutInfo.cutMinDuration < right &&
                right < _cutInfo.cutMaxDuration && right < _cutInfo.videoDuration - _cutInfo.offsetTime) {
                _cutInfo.endTime = right;
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _selectImageView = nil;
}
@end
