//
//  QPRecordTipGuideView.m
//  QupaiSDK
//
//  Created by yly on 15/6/29.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPRecordTipGuideView.h"

@implementation QPRecordTipGuideView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        return self;
    }
    return nil;
}

- (CGFloat)arrowOffsetX:(CGFloat)x atWidth:(CGFloat)w
{
    return w/2 - x;
}

- (void)addSkinGuideInPoint:(CGRect)frame
{
    UIImage *image = [QPImage imageNamed:@"tip_record_mackup"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    
    CGPoint vp = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    vp.x = vp.x + 43;
    vp.y = vp.y + CGRectGetHeight(imageView.bounds)/2.0 + CGRectGetHeight(imageView.bounds)/2.0;
    imageView.center = vp;
}


- (void)addImportGuideInPoint:(CGRect)frame
{
    UIImage *image = [QPImage imageNamed:@"guide_import"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    
    CGPoint vp = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    vp.x = vp.x + [self arrowOffsetX:40 atWidth:CGRectGetWidth(imageView.bounds)];
    vp.y = vp.y - CGRectGetHeight(imageView.bounds)/2.0 - CGRectGetHeight(frame)/2;
    imageView.center = vp;
}

- (void)addDeleteGuideInPoint:(CGRect)frame
{
    UIImage *image = [QPImage imageNamed:@"tip_record_delete1"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    
    CGPoint vp = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    vp.x = vp.x + [self arrowOffsetX:40 atWidth:CGRectGetWidth(imageView.bounds)];
    vp.y = vp.y - CGRectGetHeight(imageView.bounds)/2.0 - CGRectGetHeight(frame)/2;
    imageView.center = vp;
}

- (void)addDeleteTrashGuideInPoint:(CGRect)frame
{
    UIImage *image = [QPImage imageNamed:@"tip_record_delete"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    
    CGPoint vp = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    vp.x = vp.x + [self arrowOffsetX:40 atWidth:CGRectGetWidth(imageView.bounds)];
    vp.y = vp.y - CGRectGetHeight(imageView.bounds)/2.0 - CGRectGetHeight(frame)/2;
    imageView.center = vp;
}

- (void)removeAllGuideView
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
