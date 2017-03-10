//
//  PointProgress.m
//  Qupai_1.5_dev
//
//  Created by lyle on 13-8-29.
//  Copyright (c) 2013年 duanqu. All rights reserved.
//

#import "QPPointProgress.h"
#import "QPVideo.h"

@interface QPPointProgress()
{
    NSTimer *_timer;
    UIView *_timeView;
    UILabel *_timeLabel;
    UIImageView *_timeImageViewLeft;
    UIImageView *_timeImageViewRight;
}

@end

@implementation QPPointProgress

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)updateProgress:(CGFloat)progress
{
    [self setNeedsDisplay];
    
    if (!_timeView) {
        _timeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 33, 20)];
        _timeView.backgroundColor = [UIColor clearColor];
        _timeImageViewLeft = [[UIImageView alloc] initWithImage:[QPImage imageNamed:@"record_progress_arrow_left"]];
        _timeImageViewLeft.alpha = 0.6;
        _timeImageViewRight = [[UIImageView alloc] initWithImage:[QPImage imageNamed:@"record_progress_arrow_right"]];
        _timeImageViewRight.alpha = 0.6;
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 33, 14)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.adjustsFontSizeToFitWidth = YES;
        [_timeView addSubview:_timeImageViewLeft];
        [_timeView addSubview:_timeImageViewRight];
        [_timeView addSubview:_timeLabel];
        [self addSubview:_timeView];
    }
    
    _timeLabel.text = [NSString stringWithFormat:@"%0.1f秒",self.video.duration];
    CGRect frame = _timeView.frame;
    frame.origin.y = CGRectGetHeight(self.bounds);
    frame.origin.x = self.video.duration/self.video.maxDuration * CGRectGetWidth(self.bounds);
    if (CGRectGetMaxX(frame) > CGRectGetWidth(self.bounds) * 0.8) {
        frame.origin.x -= CGRectGetWidth(frame);
        _timeImageViewLeft.hidden = YES;
        _timeImageViewRight.hidden = NO;
    }else{
        _timeImageViewLeft.hidden = NO;
        _timeImageViewRight.hidden = YES;
    }
//    _timeView.frame = frame;
    _timeView.hidden = self.video.duration == 0;
}

- (void)setShowBlink:(BOOL)showBlink
{
    _showBlink = showBlink;
    [_timer invalidate];
    if (_showBlink) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self
                selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
    }
}

#define RGBToColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

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
    
    for (int i = 0; i < _video.pointCount; ++i) {
        QPVideoPoint *vp = [_video pointAtIndex:i];
        if (i == _video.pointCount - 1 && _video.lastSelected) {
            CGContextSetStrokeColorWithColor(context, _colorSelect.CGColor);
        }else{
            CGContextSetStrokeColorWithColor(context, _colorNomal.CGColor);
        }
        CGFloat x1 = vp.startTime/_video.maxDuration*self.frame.size.width;
        CGContextMoveToPoint(context, x1, 0);
        CGFloat x2 = vp.endTime/_video.maxDuration*self.frame.size.width-1;
        CGContextAddLineToPoint(context, x2, 0);
        CGContextStrokePath(context);
    }

    if (_showNoticePoint) {
        CGContextSetStrokeColorWithColor(context, _colorNotice.CGColor);
        CGContextMoveToPoint(context, w*(_video.minDuration/_video.maxDuration), 0);
        CGContextAddLineToPoint(context, w*(_video.minDuration/_video.maxDuration)+1,0);
        CGContextStrokePath(context);
    }
    if (_showCursor && (_showBlink ? ++_times : (_times=1)) && (_times%2 == 1)) {
        
        CGRect r = CGRectMake(0, 0, 20/2, 27/2);
        QPVideoPoint *vp = [_video lastPoint];
        if (vp) {
            CGFloat x = vp.endTime/_video.maxDuration*self.frame.size.width-1;
            r.origin.x += x;
            r.origin.y += 0;
        }
        
        CGContextSetStrokeColorWithColor(context, RGBToColor(255, 255, 255, 1).CGColor);
        CGContextMoveToPoint(context, r.origin.x, r.origin.y);
        CGContextAddLineToPoint(context, r.origin.x + 4, r.origin.y);
        CGContextStrokePath(context);
    }
}

@end
