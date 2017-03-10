//
//  QPCutCenterProgressView.m
//  QupaiSDK
//
//  Created by yly on 15/6/23.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPCutCenterProgressView.h"

@implementation QPCutCenterProgressView

- (void)updateProgress:(CGFloat)progress
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, CGRectGetHeight(self.bounds) * [[UIScreen mainScreen] scale]);
    
    CGFloat w = CGRectGetWidth(self.superview.bounds);
    
    if (_colorBg) {
        CGContextSetStrokeColorWithColor(context, _colorBg.CGColor);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, w, 0);
        CGContextStrokePath(context);
    }

    CGContextSetStrokeColorWithColor(context, _colorSelect.CGColor);
    CGContextMoveToPoint(context, self.frame.size.width * _startTime, 0);
    CGContextAddLineToPoint(context, self.frame.size.width * _endTime, 0);
    CGContextStrokePath(context);
}

@end
