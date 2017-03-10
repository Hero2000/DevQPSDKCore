//
//  GuideView.m
//  duanqu2
//
//  Created by lyle on 13-5-31.
//  Copyright (c) 2013年 duanqu. All rights reserved.
//

#import "QPRecordGuideView.h"
#import "QPGuideFactory.h"

typedef enum GuideStep : NSUInteger{
    GuideStepNone,
    GuideStepDoing,
    GuideStepDone,
    
    RecordNone,
    RecordStart,
    RecordDoing,
    RecordPause,
    RecordFocus,
    RecordEffect,
}GuideStep;

#define kCenterFrame CGRectMake(60, 83, 200, 50)

@interface QPRecordGuideView()
{
    GuideStep _guide1,_guide2,_guide3,_guide4,_guide5;
    
    float _time1,_time2,_time3,_time4,_time5;
    
    float _recordTime;
    
    GuideStep _recordStatus;
    
    UIView *_viewTipTextBox;
}
@end

@implementation QPRecordGuideView

+ (BOOL)isFour
{
    return [[UIScreen mainScreen] bounds].size.height == 568;
}

- (void)setup
{
    _time1 = 0.0; _time2 = _time1; _time3 = _time2;
    _time4 = 2.0; _time5 = 8.0;
}

- (void)resetState
{
    _recordTime = 0.0;
    
    _guide1 = GuideStepNone;
    _guide2 = GuideStepNone;
    _guide3 = GuideStepNone;
    _guide4 = GuideStepNone;
    _guide5 = GuideStepNone;
    
    _recordStatus = RecordNone;
}


- (void)recordStart
{
    [self resetState];
    _recordStatus = RecordStart;
    [self recordTimeUpdate:_recordTime];
}

- (void)recordDoing
{
    _recordStatus = RecordDoing;
    [self recordTimeUpdate:_recordTime];
}

- (void)recordPause
{
    _recordStatus = RecordPause;
    [self recordTimeUpdate:_recordTime];
}

- (void)recordFocus
{
    _recordStatus = RecordFocus;
    [self recordTimeUpdate:_recordTime];
}

- (void)recordEffect
{
    _recordStatus = RecordEffect;
    [self recordTimeUpdate:_recordTime];
}

- (void)recordFinish
{
    [self replaceGuideView:nil];
}

- (void)jumpToTime:(CGFloat)time
{
    {
        _time1 = 0.0; _time2 = 0.5; _time3 = _time2;
        _time4 = 2.0; _time5 = 8.0;
        if (time <= _time2) {_guide3=GuideStepNone;_guide2=GuideStepNone;_guide1=GuideStepNone;};
        if (time <= _time4) {_guide5=GuideStepNone;_guide4=GuideStepNone;
                             _guide3=GuideStepNone;};
    }
    [self recordTimeUpdate:time];
}


- (void)replaceGuideView:(UIView *)view
{
    if (!_viewTipTextBox) {
        CGRect frame = self.bounds;
        frame.origin.y = CGRectGetHeight(frame) - 36;
        frame.size.height = 36;
        _viewTipTextBox = [[UIView alloc] initWithFrame:frame];
        [self addSubview:_viewTipTextBox];
    }
    static NSInteger ViewTag = 100;
    [[_viewTipTextBox subviews] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = (UIView *)obj;
        if (view.tag == ViewTag) {
            [view removeFromSuperview];
        }
    }];
    if (view) {
        view.tag = ViewTag;
        [_viewTipTextBox addSubview:view];
    }
}

- (void)normalRecordTimeUpdate:(float)time
{
    _time1 = 0.0; _time2 = 0.5; _time3 = _time2;
    _time4 = _time2; _time5 = 2.0;
    
    if (time >= _time1) {
        if (_guide1 == GuideStepNone/* && _recordStatus == RecordStart*/) {
            [self replaceGuideView:[QPGuideFactory createRecordDown]];//按住屏幕或录制按钮进行拍摄
            _guide1 = GuideStepDoing;
        }else if(_guide1 == GuideStepDoing && _recordStatus == RecordDoing){
            _guide1 = GuideStepDone;
        }
    }
    if (time >= _time2 && _guide1 == GuideStepDone) {
        if (_guide2 == GuideStepNone) {
            [self replaceGuideView:[QPGuideFactory createRecordUpPause]];//松开暂停
            _guide2 = GuideStepDoing;
            
            //[_delegate guideViewNeedStopRecord:self]; //
        }else if(_guide2 == GuideStepDoing && _recordStatus == RecordPause){
            _guide2 = GuideStepDone;
        }
    }
    
    if (time >= _time3 && _guide2 == GuideStepDone) {
        if (_guide3 == GuideStepNone) {
            [self replaceGuideView:[QPGuideFactory createRecordChangeScene]];//换个场景，按住继续拍摄
            _guide3 = GuideStepDoing;
        }else if(_guide3 == GuideStepDoing && _recordStatus == RecordDoing){
            _guide3 = GuideStepDone;
        }
    }
    if (time > _time4 && _guide3 == GuideStepDone) {
        if (_guide4 == GuideStepNone) {
            [self replaceGuideView:[QPGuideFactory createRecordTime]];//可录制2至8 秒时长的视频
            _guide4 = GuideStepDoing;
           // [_delegate guideViewNeedStopRecord:self]; //
        }else if(_guide4 == GuideStepDoing && _recordStatus == RecordPause){
            _guide4 = GuideStepDone;
        }
    }
    if (time > _time5 && _guide4 == GuideStepDone) {
        if (_guide5 == GuideStepNone) {
            [self replaceGuideView:[QPGuideFactory createRecordFinish]];//继续拍摄或点击->预览
            _guide5 = GuideStepDoing;
        }else if(_guide5 == GuideStepDoing && _recordStatus == RecordPause){
            _guide5 = GuideStepDone;
        }
    }
    
    _recordTime = time;
}

- (void)recordTimeUpdate:(float)time
{
    [self normalRecordTimeUpdate:time];
}

@end
