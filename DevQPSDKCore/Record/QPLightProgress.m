//
//  QULightProgress.m
//  qupai
//
//  Created by yly on 14/12/22.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import "QPLightProgress.h"

@implementation QPLightProgress
{
    UIImageView *_imageViewAdd;
    UIImageView *_imageViewSub;
    UIImageView *_imageViewLight;
    
    CGFloat _lineAddYFrom;
    CGFloat _lineAddYTo;
    CGFloat _lineSubYFrom;
    CGFloat _lineSubTo;
    
    CGFloat _lineX;
    CGFloat _lineCap;
    CGFloat _lineHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor clearColor];
    
    _imageViewAdd = [[UIImageView alloc] initWithImage:[QPImage imageNamed:@"Nightmode_sliderbar_+"]];
    _imageViewLight = [[UIImageView alloc] initWithImage:[QPImage imageNamed:@"Nightmode_sliderbar_sun"]];
    _imageViewSub = [[UIImageView alloc] initWithImage:[QPImage imageNamed:@"Nightmode_sliderbar_-"]];
    
    [self addSubview:_imageViewAdd];
    [self addSubview:_imageViewLight];
    [self addSubview:_imageViewSub];
    
    _lineCap = 2;
    _lineX = CGRectGetWidth(frame)/2.0;
    return self;
}

- (void)refreshPosition
{
//    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat addH = CGRectGetHeight(_imageViewAdd.bounds);
    CGFloat subH = CGRectGetHeight(_imageViewSub.bounds);
    CGFloat lightH = CGRectGetHeight(_imageViewLight.bounds);
    CGFloat lineH = h - addH - subH - lightH - _lineCap * 4;
    CGFloat y = 0;
    
    y += addH/2.0;
    _imageViewAdd.center = CGPointMake(_lineX, y);
    
    y += addH/2.0 + _lineCap;
    _lineAddYFrom = y;
    
    y += lineH * ( 1- _progress);
    _lineAddYTo = y;
    
    y += _lineCap + lightH/2.0;
    _imageViewLight.center = CGPointMake(_lineX, y);
    
    y += lightH/2.0 + _lineCap;
    _lineSubYFrom = y;
    
    y += lineH * _progress;
    _lineSubTo = y;
    
    y += _lineCap + subH/2.0;
    _imageViewSub.center = CGPointMake(_lineX, y);
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self refreshPosition];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [QupaiSDK shared].tintColor.CGColor);
    
    CGContextMoveToPoint(context, _lineX, _lineSubYFrom);
    CGContextAddLineToPoint(context, _lineX, _lineSubTo);
    CGContextStrokePath(context);

    CGContextMoveToPoint(context, _lineX, _lineAddYFrom);
    CGContextAddLineToPoint(context, _lineX, _lineAddYTo);
    CGContextStrokePath(context);
}

@end
