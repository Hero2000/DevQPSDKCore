//
//  QPGuideFactory.m
//  QupaiSDK
//
//  Created by lyle on 14-3-25.
//  Copyright (c) 2014年 lyle. All rights reserved.
//

#import "QPGuideFactory.h"

@implementation QPGuideFactory

#pragma mark - Normal Gudie

+ (UIView *)createViewBg
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 36)];
    view.backgroundColor = RGBToColor(255, 255, 255, 0.7);
    return view;
}

+ (UILabel *)createYellowLabel:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 200, 36-8)];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:19];
    label.textColor = RGBToColor(255, 0, 0, 1);
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    return label;
}

+ (UILabel *)createWhiteLabel:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, 200, 36-11)];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = RGBToColor(255, 255, 255, 1);
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    return label;
}

+(void)layoutView:(UIView *)view v1:(UIView *)v1 v2:(UIView *)v2 v3:(UIView *)v3
{
    [QPGuideFactory layoutView:view v1:v1 v2:v2 v3:v3 v4:nil v5:nil];
}

+(void)layoutView:(UIView *)view v1:(UIView *)v1 v2:(UIView *)v2 v3:(UIView *)v3 v4:(UIView *)v4 v5:(UIView *)v5
{
    CGFloat w = view.bounds.size.width;
    CGFloat w1 = v1.frame.size.width;
    CGFloat w2 = v2.frame.size.width;
    CGFloat w3 = v3.frame.size.width;
    CGFloat w4 = v4.frame.size.width;
    CGFloat w5 = v5.frame.size.width;
    
    CGFloat s = (w - (w1 + w2 + w3 + w4 + w5))/2;
    
    CGPoint p = CGPointMake(s, 0);
    p.x += w1/2;
    p.y = v1.center.y;
    v1.center = p;
    
    p.x += w1/2;
    p.x += w2/2;
    p.y = v2.center.y;
    v2.center = p;
    
    p.x += w2/2;
    p.x += w3/2;
    p.y = v3.center.y;
    v3.center = p;
    
    p.x += w3/2;
    p.x += w4/2;
    p.y = v4.center.y;
    v4.center = p;
    
    p.x += w4/2;
    p.x += w5/2;
    p.y = v5.center.y;
    v5.center = p;
}

+ (UIView *)createRecordDown
{
    UIView *view = [self createViewBg];
    UILabel *label1 = [self createYellowLabel:@"按住"];
    [view addSubview:label1];
    UILabel *label2 = [self createWhiteLabel:@"拍摄按钮进行拍摄"];
    [view addSubview:label2];
    
    [self layoutView:view v1:label1 v2:label2 v3:nil];
    
    return view;
}

+ (UIView *)createRecordUp
{
    UIView *view = [self createViewBg];
    UILabel *label1 = [self createYellowLabel:@"按住"];
    [view addSubview:label1];
    UILabel *label2 = [self createWhiteLabel:@"不要松手哦"];
    [view addSubview:label2];
    
    [self layoutView:view v1:label1 v2:label2 v3:nil];
    
    return view;
}

+ (UIView *)createRecordUpPause
{
    UIView *view = [self createViewBg];
    UILabel *label1 = [self createYellowLabel:@""];
    [view addSubview:label1];
    UILabel *label2 = [self createWhiteLabel:@"松开暂停"];
    [view addSubview:label2];
    
    [self layoutView:view v1:label1 v2:label2 v3:nil];
    
    return view;
}

+ (UIView *)createRecordChangeScene
{
    UIView *view = [self createViewBg];
    UILabel *label1 = [self createWhiteLabel:@"换个场景,"];
    [view addSubview:label1];
    UILabel *label2 = [self createYellowLabel:@"按住"];
    [view addSubview:label2];
    UILabel *label3 = [self createWhiteLabel:@"继续拍摄"];
    [view addSubview:label3];
    
    [self layoutView:view v1:label1 v2:label2 v3:label3];
    
    return view;
}

+ (UIView *)createRecordTime
{
    UIView *view = [self createViewBg];
    UILabel *label1 = [self createWhiteLabel:@"可录制"];
    [view addSubview:label1];
    NSString *msg = [NSString stringWithFormat:@"%0.0f至%0.0f秒",QupaiSDK.shared.minDuration, QupaiSDK.shared.maxDuration];
    UILabel *label2 = [self createYellowLabel:msg];
    [view addSubview:label2];
    UILabel *label3 = [self createWhiteLabel:@"时长的视频"];
    [view addSubview:label3];
    
    [self layoutView:view v1:label1 v2:label2 v3:label3];
    
    return view;
}

+ (UIView *)createRecordFinish
{
    UIView *view = [self createViewBg];
    UILabel *label1 = [self createWhiteLabel:@"继续"];
    [view addSubview:label1];
    UILabel *label2 = [self createYellowLabel:@"拍摄"];
    [view addSubview:label2];
    UILabel *label3 = [self createWhiteLabel:@"或点击"];
    [view addSubview:label3];
    
    UIImage *image = [QPImage imageNamed:@"dub_ico_confirm"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 8, 30, 20);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:imageView];
    
    UILabel *label4 = [self createWhiteLabel:@"预览"];
    [view addSubview:label4];
    
    [self layoutView:view v1:label1 v2:label2 v3:label3 v4:imageView v5:label4];
    
    return view;
}

+ (UIView *)createRotateShoot
{
    UIView *view = [self createViewBg];
    UILabel *label1 = [self createWhiteLabel:@"建议"];
    [view addSubview:label1];
    UILabel *label2 = [self createYellowLabel:@"竖屏"];
    [view addSubview:label2];
    UILabel *label3 = [self createWhiteLabel:@"拍摄，便于观看"];
    [view addSubview:label3];
    
    [self layoutView:view v1:label1 v2:label2 v3:label3];
    
    return view;
}

+ (UIView *)createRecordAudioDown
{
    UIView *view = [self createViewBg];
    UILabel *label1 = [self createYellowLabel:@"按住"];
    [view addSubview:label1];
    UILabel *label2 = [self createWhiteLabel:@"按钮进行配音，"];
    [view addSubview:label2];
    UILabel *label3 = [self createYellowLabel:@"松开"];
    [view addSubview:label3];
    UILabel *label4 = [self createWhiteLabel:@"暂停"];
    [view addSubview:label4];
    
    [self layoutView:view v1:label1 v2:label2 v3:label3 v4:label4 v5:nil];
    
    return view;
}

+(UIView *)createNoticeDeleteGuide
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 147, 54)];
    view.backgroundColor = [UIColor clearColor];
    UIImage *image = [QPImage imageNamed:@"tip_record_delete1"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = view.bounds;
    [view addSubview:imageView];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
//    label.textAlignment = NSTextAlignmentLeft;
//    label.textColor = [UIColor whiteColor];
//    label.text = @"删除不满意的片段";
//    label.numberOfLines = 1;
//    label.font = [UIFont systemFontOfSize:13];
//    label.backgroundColor = [UIColor clearColor];
//    [view addSubview:label];
    
    view.userInteractionEnabled = NO;
    
    return view;
}

+(UIView *)createDeleteGuide
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 131, 69)];
    view.backgroundColor = [UIColor clearColor];
    UIImage *image = [QPImage imageNamed:@"tip_record_delete"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = view.bounds;
    [view addSubview:imageView];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
//    label.textAlignment = NSTextAlignmentLeft;
//    label.textColor = [UIColor whiteColor];
//    label.text = @"再次点击将删除最后一段视频";
//    label.numberOfLines = 1;
//    label.font = [UIFont systemFontOfSize:13];
//    label.backgroundColor = [UIColor clearColor];
//    [view addSubview:label];
    
    view.userInteractionEnabled = NO;
    
    return view;
}

+(UIView *)createBeautyGuide
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 202, 55)];
    view.backgroundColor = [UIColor clearColor];
    UIImage *image = [QPImage imageNamed:@"tip_record_mackup"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = view.bounds;
    [view addSubview:imageView];
    
    view.userInteractionEnabled = NO;
    
    return view;
}

+(UIView *)createImportGuide
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 70)];
    view.backgroundColor = [UIColor clearColor];
    UIImage *image = [QPImage imageNamed:[QPSDKConfig is40] ? @"guide_arrow_down" : @"guide_arrow_down_small"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = [QPSDKConfig is40] ? CGRectMake(38, 20, 25, 38) : CGRectMake(38, 20, 11, 15);
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.text = @"可以导入本地视频啦";
    label.numberOfLines = 1;
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    view.userInteractionEnabled = NO;
    
    return view;
}

+(UIView *)createSaveGuide
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 70)];
    view.backgroundColor = [UIColor clearColor];
    UIImage *image = [QPImage imageNamed:[QPSDKConfig is40] ? @"guide_arrow_down" : @"guide_arrow_down_small"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = [QPSDKConfig is40] ? CGRectMake(38, 20, 25, 38) : CGRectMake(38, 20, 11, 15);
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.text = @"保存好的视频在这里";
    label.numberOfLines = 1;
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    view.userInteractionEnabled = NO;
    
    return view;
}


+(UIView *)createPasterRotate
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 130, 70)];
    view.backgroundColor = [UIColor clearColor];
    UIImage *image = [QPImage imageNamed:@"guide_arrow_on"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(45, 0, 36, 28);
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 130, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.text = @"手指按住这里拖动";
    label.numberOfLines = 1;
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = RGBToColor(0, 0, 0, 0.3);
    [view addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 130, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.text = @"调整大小和旋转角度";
    label.numberOfLines = 1;
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = RGBToColor(0, 0, 0, 0.3);
    [view addSubview:label];
    
    view.userInteractionEnabled = NO;
    
    return view;
}

+ (UIView *)createDragText{
    UIView *view = [self createViewBg];
    UIImageView *image = [[UIImageView alloc]initWithFrame:view.frame];
    image.backgroundColor = [UIColor whiteColor];
    image.alpha = 0.3;
    [view addSubview:image];
    
    UILabel *label1 = [self createYellowLabel:@"拖动"];
    [view addSubview:label1];
    UILabel *label2 = [self createWhiteLabel:@"视频调整显示区域"];
    [view addSubview:label2];
    [self layoutView:view v1:label1 v2:label2 v3:nil];
    return view;
}


+ (UIView *)createDragVideo
{
    //    UIView *view = [self createViewBg];
    //    UILabel *label1 = [self createYellowLabel:@"拖动"];
    //    [view addSubview:label1];
    //    UILabel *label2 = [self createWhiteLabel:@"视频,调整显示区域"];
    //    [view addSubview:label2];
    //
    //    [self layoutView:view v1:label1 v2:label2 v3:nil];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
    view.userInteractionEnabled = NO;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[QPImage imageNamed:@"cut_guide_dragvideo"]];
    imageView.center = CGPointMake(ScreenWidth/2, ScreenWidth/2);
    [view addSubview:imageView];
    
    UIView *text = [self createDragText];
    text.center = CGPointMake(ScreenWidth/2, CGRectGetHeight(text.frame)/2);
    [view addSubview:text];
    return view;
}

+ (UIView *)createDragTimer
{
    UIView *view = [self createViewBg];
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = NO;
    UILabel *label1 = [self createYellowLabel:@"拖动"];
    [view addSubview:label1];
    UILabel *label2 = [self createWhiteLabel:@"手柄或视频缩略图,调整裁剪时间"];
    [view addSubview:label2];
    
    [self layoutView:view v1:label1 v2:label2 v3:nil];
    
    return view;
}



@end
