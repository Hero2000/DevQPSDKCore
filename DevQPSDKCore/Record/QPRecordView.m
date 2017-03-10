//
//  QPRecordView.m
//  QPSDK
//
//  Created by LYZ on 16/4/25.
//  Copyright © 2016年 danqoo. All rights reserved.
//

#import "QPRecordView.h"
#import "QPPointProgress.h"


#define kViewTopButtonWeight 44
#define kViewTopButtonScale 18

#define kViewProgressHeight 4

//#define kViewBottomHeight (ScreenHeight - kViewTopButtonWeight - kViewProgressHeight - ScreenWidth)
#define kButtonLibraryWeight 55
#define kButtonRecordWeight 85

#define kViewTimeHeight 72

@interface QPRecordView ()
@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) CGFloat bottomPanelHeight;
@end

@implementation QPRecordView

-(instancetype)initWithFrame:(CGRect)frame videoSize:(CGSize)videoSize bottomPanelHeight:(CGFloat)height {
    self = [super initWithFrame:frame];
    if (self) {
        self.videoSize = videoSize;
        self.bottomPanelHeight = height;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    
    self.backgroundColor = [UIColor blackColor];
    
    [self setupTopViews];
    
    [self setupProgress];
    
    [self setupBottomViews];
    
    [self setupCenterViews];
    
    [self centerViewAddGestures];
    
     [self sendSubviewToBack:self.viewCenter];
}


- (void)setupTopViews {
    
    // topView
    self.viewTop = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, ScreenWidth, 44))];
    self.viewTop.backgroundColor = RGBToColor(255, 255, 255, 0.1);
    [self addSubview:self.viewTop];
    
    self.buttonClose = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonClose.frame = CGRectMake(0, 0, kViewTopButtonWeight, kViewTopButtonWeight);
    [self.buttonClose addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.buttonClose setImage:[QPImage imageNamed:@"record_ico_close.png"] forState:(UIControlStateNormal)];
    [self.viewTop addSubview:self.buttonClose];
    
    self.buttonPosition = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonPosition.frame = CGRectMake(CGRectGetWidth(self.viewTop.frame) - kViewTopButtonWeight, 0, kViewTopButtonWeight, kViewTopButtonWeight);
    [self.buttonPosition setImage:[QPImage imageNamed:@"record_ico_switch.png"] forState:(UIControlStateNormal)];
    [self.buttonPosition setImage:[QPImage imageNamed:@"record_ico_switch_1.png"] forState:(UIControlStateSelected)];
    [self.buttonPosition addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewTop addSubview:self.buttonPosition];
    
    self.buttonTime = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonTime.frame = CGRectMake(CGRectGetMinX(self.buttonPosition.frame) - kViewTopButtonWeight - kViewTopButtonScale, 0, kViewTopButtonWeight, kViewTopButtonWeight);
    [self.buttonTime setImage:[QPImage imageNamed:@"record_ico_countdown.png"] forState:(UIControlStateNormal)];
    [self.buttonTime setImage:[QPImage imageNamed:@"record_ico_countdown_1.png"] forState:(UIControlStateSelected)];
    [self.buttonTime addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewTop addSubview:self.buttonTime];
    
    self.buttonSkin = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonSkin.frame = CGRectMake(CGRectGetMinX(self.buttonTime.frame) - kViewTopButtonWeight - kViewTopButtonScale, 0, kViewTopButtonWeight, kViewTopButtonWeight);
    [self.buttonSkin addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.buttonSkin setImage:[QPImage imageNamed:@"record_ico_mackup.png"] forState:(UIControlStateNormal)];
    [self.buttonSkin setImage:[QPImage imageNamed:@"record_ico_mackup_1.png"] forState:(UIControlStateSelected)];
    [self.viewTop addSubview:self.buttonSkin];
    
    self.skinBgImage = [[UIImageView alloc] initWithFrame:self.buttonSkin.frame];
    
    NSMutableArray *makeupIcos = [[NSMutableArray alloc]initWithCapacity:26];
    NSMutableArray *makeupImages = [[NSMutableArray alloc]initWithCapacity:29];
    for (int i = 0; i < 29; i++) {
        NSString *imageFrame = [NSString stringWithFormat:@"makeup_img_frame_%05d.png",i];
        if (i < 26) {
            NSString *icoFrame = [NSString stringWithFormat:@"ico_mackup_%05d.png",i];
            [makeupIcos addObject:[QPImage imageNamed:icoFrame]];
            [makeupImages addObject:[QPImage imageNamed:imageFrame]];
        } else {
            [makeupImages addObject:[QPImage imageNamed:imageFrame]];
        }
    }
    
    NSArray *skinImageArray = [NSArray arrayWithArray:makeupIcos];
    [self.skinBgImage setImage:[UIImage animatedImageWithImages:skinImageArray duration:2]];
    [self.viewTop addSubview:self.skinBgImage];

}


- (void)setupProgress {
    
    // viewProgress
    self.viewProgress = [[UIView alloc] initWithFrame:(CGRectMake(CGRectGetMinX(self.viewTop.frame), CGRectGetMaxY(self.viewTop.frame), CGRectGetWidth(self.viewTop.frame), kViewProgressHeight))];
    self.viewProgress.backgroundColor = RGBToColor(0,0,0, 0.1);
    [self addSubview:self.viewProgress];
    
    self.pointProgress = [[QPPointProgress alloc] initWithFrame:self.viewProgress.frame];
    [self addSubview:self.pointProgress];
}


- (void)setupCenterViews {
    CGFloat ratio = self.videoSize.height / self.videoSize.width;
    CGFloat centerTop = kViewTopButtonWeight + kViewProgressHeight;
    CGFloat centerHeight = CGRectGetWidth(self.frame) * ratio;
    if (centerHeight > CGRectGetHeight(self.frame)) {
        centerTop = -(centerHeight - CGRectGetHeight(self.frame))/2.0f;
    }else if (centerHeight > (CGRectGetHeight(self.frame) -  kViewTopButtonWeight - kViewProgressHeight)) {
        centerTop = 0;
    }
    // centerView
    self.viewCenter = [[UIView alloc] initWithFrame:CGRectMake(0, centerTop, CGRectGetWidth(self.viewTop.frame), centerHeight)];
    self.viewCenter.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewCenter];
    
    self.gpuImageView = [[UIView alloc] init];
//    self.gpuImageView.fillMode = kQPGPUImageFillModePreserveAspectRatioAndFill;
    self.gpuImageView.backgroundColor = [UIColor blackColor];
    self.gpuImageView.frame = self.viewCenter.bounds;
    [self.viewCenter addSubview:self.gpuImageView];
    
    self.viewFocusContent = [[UIView alloc] initWithFrame:self.viewCenter.bounds];
    self.viewMask = [[UIView alloc] initWithFrame:self.viewFocusContent.frame];
    self.viewMask.hidden = YES;
    self.viewMask.backgroundColor = [UIColor clearColor];
    [self.viewFocusContent addSubview:self.viewMask];
    [self.viewCenter addSubview:self.viewFocusContent];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    self.activityIndicator.center = self.viewCenter.center;
    self.activityIndicator.hidesWhenStopped = YES;
    [self addSubview:self.activityIndicator];
    
    // centerView viewSkin
    self.viewSkin = [[UIView alloc] initWithFrame:(CGRectMake(3, CGRectGetHeight(self.frame) - 36 - 32 - _bottomPanelHeight, CGRectGetWidth(self.viewCenter.frame) - 6, 32))];
    [self addSubview:self.viewSkin];
    
    UIImageView *viewSkinBg = [[UIImageView alloc] initWithFrame:self.viewSkin.bounds];
    viewSkinBg.image = [QPImage imageNamed:@"record_levelbase_bg.png"];
    [self.viewSkin addSubview:viewSkinBg];
    
    UILabel *labelSkin = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 50, CGRectGetHeight(self.viewSkin.frame)))];
    labelSkin.text = @"美颜";
    labelSkin.textAlignment = NSTextAlignmentCenter;
    labelSkin.textColor = [UIColor whiteColor];
    labelSkin.font = [UIFont systemFontOfSize:11.f];
    [self.viewSkin addSubview:labelSkin];
    
    self.labelSkinRight = [[UILabel alloc] initWithFrame:(CGRectMake(CGRectGetWidth(self.viewSkin.frame) - 50, 0, 50, CGRectGetHeight(self.viewSkin.frame)))];
    self.labelSkinRight.text = @"80%";
    self.labelSkinRight.textAlignment = NSTextAlignmentCenter;
    self.labelSkinRight.textColor = [UIColor whiteColor];
    self.labelSkinRight.font = [UIFont systemFontOfSize:11.f];
    [self.viewSkin addSubview:self.labelSkinRight];
    
    self.sliderSkin = [[UISlider alloc] initWithFrame: CGRectMake(CGRectGetMaxX(labelSkin.frame) + 2, 0, CGRectGetMinX(self.labelSkinRight.frame) - CGRectGetMaxX(labelSkin.frame) - 4, 100)];
    self.sliderSkin.center = CGPointMake(self.sliderSkin.center.x, CGRectGetHeight(self.viewSkin.frame) / 2);
    self.sliderSkin.value = 0.8;
    [self.viewSkin addSubview:self.sliderSkin];
    
    self.viewSkin.hidden = YES;
    self.labelSkinRight.hidden = YES;
    
    // centerView ViewTimeNotice
    self.viewTimeNotice = [[UIView alloc] initWithFrame:(CGRectMake(0, (CGRectGetWidth(self.viewCenter.frame) - kViewTimeHeight) / 2, CGRectGetWidth(self.viewCenter.frame), kViewTimeHeight))];
    [self.viewCenter addSubview:self.viewTimeNotice];
    
    self.viewTimeNoticeTop = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.viewTimeNotice.frame), kViewTimeHeight / 2))];
    self.viewTimeNoticeTop.text = @"5 秒后将开始自动拍摄";
    self.viewTimeNoticeTop.textColor = [UIColor whiteColor];
    self.viewTimeNoticeTop.textAlignment = NSTextAlignmentCenter;
    self.viewTimeNoticeTop.font = [UIFont boldSystemFontOfSize:21.f];
    [self.viewTimeNotice addSubview:self.viewTimeNoticeTop];
    
    self.viewTimeNoticeBottom = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewTimeNoticeTop.frame), CGRectGetWidth(self.viewTimeNotice.frame), kViewTimeHeight / 2))];
    UIView *leftView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.viewTimeNoticeBottom.frame) * 0.45 , CGRectGetHeight(self.viewTimeNoticeBottom.frame)))];
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(leftView.frame) - 22, CGRectGetHeight(leftView.frame)))];
    leftLabel.text = @"点击";
    leftLabel.textColor = [UIColor whiteColor];
    leftLabel.font = [UIFont boldSystemFontOfSize:21.f];
    leftLabel.textAlignment = NSTextAlignmentRight;
    [leftView addSubview:leftLabel];
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:(CGRectMake(CGRectGetMaxX(leftLabel.frame), 0, 22, 22))];
    leftImageView.center = CGPointMake(leftImageView.center.x, leftLabel.center.y);
    leftImageView.image = [QPImage imageNamed:@"record_tip_ico_countdown.png"];
    [leftView addSubview:leftImageView];
    [self.viewTimeNoticeBottom addSubview:leftView];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:(CGRectMake(CGRectGetMaxX(leftView.frame), 0, CGRectGetWidth(self.viewTimeNoticeBottom.frame) - CGRectGetWidth(leftView.frame), CGRectGetHeight(self.viewTimeNoticeBottom.frame)))];
    rightLabel.textAlignment = NSTextAlignmentLeft;
    rightLabel.text = @"退出倒计时";
    rightLabel.textColor = [UIColor whiteColor];
    rightLabel.font = [UIFont boldSystemFontOfSize:21.f];
    [self.viewTimeNoticeBottom addSubview:rightLabel];
    
    [self.viewTimeNotice addSubview:self.viewTimeNoticeBottom];
    
    self.viewTimeNotice.hidden = YES;
    
    // centerView labelOrientation
    self.labelOrientation = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.viewCenter.frame), 44))];
    self.labelOrientation.font = [UIFont systemFontOfSize:17.f];
    self.labelOrientation.textColor = [UIColor redColor];
    self.labelOrientation.textAlignment = NSTextAlignmentLeft;
    [self.viewCenter addSubview:self.labelOrientation];
    
    // centerView viewScale
    self.viewScale = [[UIView alloc] initWithFrame:(CGRectMake((CGRectGetWidth(self.viewCenter.frame) - 58) / 2, (CGRectGetHeight(self.viewCenter.frame) - 22) / 2, 58, 22))];
    UIImageView *viewScaleBg = [[UIImageView alloc] initWithFrame:self.viewScale.bounds];
    viewScaleBg.image = [QPImage imageNamed:@"record_zoomlens_bg.png"];
    [self.viewScale addSubview:viewScaleBg];
    UIImageView *viewScaleIcon = [[UIImageView alloc] initWithFrame:(CGRectMake(5, (CGRectGetHeight(self.viewScale.frame) - 13) / 2, 13, 13))];
    viewScaleIcon.image = [QPImage imageNamed:@"record_zoomlens_ico.png"];
    [self.viewScale addSubview:viewScaleIcon];
    
    self.labelScale = [[UILabel alloc] initWithFrame:(CGRectMake(CGRectGetMaxX(viewScaleIcon.frame), 0, CGRectGetWidth(self.viewScale.frame) - CGRectGetMaxX(viewScaleIcon.frame) - 5, CGRectGetHeight(self.viewScale.frame)))];
    self.labelScale.text = @"X 1.0";
    self.labelScale.textColor = [UIColor whiteColor];
    self.labelScale.textAlignment = NSTextAlignmentRight;
    self.labelScale.font = [UIFont systemFontOfSize:12.f];
    [self.viewScale addSubview:self.labelScale];
    
    [self.viewCenter addSubview:self.viewScale];
    self.viewScale.hidden = YES;

}


- (void)setupBottomViews {
    
    // bottomView
    self.viewBottom = [[UIView alloc] initWithFrame:(CGRectMake(0, ScreenHeight - self.bottomPanelHeight, ScreenWidth, self.bottomPanelHeight))];
    self.viewBottom.backgroundColor = RGBToColor(255,255,255, 0.1);
    [self addSubview:self.viewBottom];
    
    UITapGestureRecognizer *bottomTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomGestureAction:)];
    
    [self.viewBottom addGestureRecognizer:bottomTap];
    
    self.buttonLibrary = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.buttonLibrary setImage:[QPImage imageNamed:@"record_ico_input.png"] forState:(UIControlStateNormal)];
    [self.buttonLibrary addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    self.buttonLibrary.frame = CGRectMake(29, (self.bottomPanelHeight - kButtonLibraryWeight) / 2, kButtonLibraryWeight, kButtonLibraryWeight);
    [self.viewBottom addSubview:self.buttonLibrary];
    
    self.buttonRecord = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.buttonRecord addTarget:self action:@selector(buttonRecordDownAction:) forControlEvents:(UIControlEventTouchDown)];
    [self.buttonRecord addTarget:self action:@selector(buttonRecordUpAction:) forControlEvents:(UIControlEventTouchUpOutside | UIControlEventTouchUpInside)];
    self.buttonRecord.frame = CGRectMake((ScreenWidth - kButtonRecordWeight) / 2, (self.bottomPanelHeight - kButtonRecordWeight) / 2, kButtonRecordWeight, kButtonRecordWeight);
    [self.buttonRecord setImage:[QPImage imageNamed:@"record_ico_rec.png"] forState:(UIControlStateNormal)];
    [self.buttonRecord setImage:[QPImage imageNamed:@"record_ico_rec_1.png"] forState:(UIControlStateHighlighted)];
    self.buttonRecord.adjustsImageWhenHighlighted = NO;
    [self.viewBottom addSubview:self.buttonRecord];
    
    self.buttonFinish = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.buttonFinish addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.buttonFinish setImage:[QPImage imageNamed:@"record_ico_check_dis.png"] forState:(UIControlStateDisabled)];
    [self.buttonFinish setImage:[QPImage imageNamed:@"record_ico_check_on.png"] forState:(UIControlStateNormal)];
    self.buttonFinish.frame = CGRectMake(CGRectGetWidth(self.viewBottom.frame) - kButtonLibraryWeight - 29, CGRectGetMinY(self.buttonLibrary.frame), kButtonLibraryWeight, kButtonLibraryWeight);
    [self.viewBottom addSubview:self.buttonFinish];
    
    // 趣拍 logo
    self.qupaiLogo = [[UILabel alloc] initWithFrame:(CGRectMake((ScreenWidth - 94) / 2, ScreenHeight - 21, 94, 21))];
    self.qupaiLogo.text = @"拍摄技术由趣拍提供";
    self.qupaiLogo.textAlignment = NSTextAlignmentCenter;
    self.qupaiLogo.font = [UIFont systemFontOfSize:8.f];
    self.qupaiLogo.textColor = [UIColor grayColor];
    [self addSubview:self.qupaiLogo];
    self.qupaiLogo.hidden = YES;
    
}


- (void)centerViewAddGestures {
    // centerView 手势
    UITapGestureRecognizer *centerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerGestureAction:)];
    [self.viewCenter addGestureRecognizer:centerTap];
    
    UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(centerGestureAction:)];
    [self.viewCenter addGestureRecognizer:centerPan];
    
    UIPinchGestureRecognizer *centerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(centerGestureAction:)];
    [self.viewCenter addGestureRecognizer:centerPinch];
}


- (void)buttonAction:(UIButton *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClickButtonCloseAction:)] && [sender isEqual:self.buttonClose]) {
        
        [_delegate onClickButtonCloseAction:sender];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClickButtonPositionAction:)] && [sender isEqual:self.buttonPosition]) {
        
        [_delegate onClickButtonPositionAction:sender];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onCLickButtonTimeAction:)] && [sender isEqual:self.buttonTime]) {
        
        [_delegate onCLickButtonTimeAction:sender];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClickButtonSkinAction:)] && [sender isEqual:self.buttonSkin]) {
        [_delegate onClickButtonSkinAction:sender];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClickButtonLibraryAction:)] && [sender isEqual:self.buttonLibrary]) {
        [_delegate onClickButtonLibraryAction:sender];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClickButtonFinishAction:)] && [sender isEqual:self.buttonFinish]) {
        [_delegate onClickButtonFinishAction:sender];
    }
}


- (void)buttonRecordDownAction:(UIButton *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClickButtonRecordDownAction:)]) {
        [_delegate onClickButtonRecordDownAction:sender];
    }
}


- (void)buttonRecordUpAction:(UIButton *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClickButtonRecordUpAction:)]) {
        [_delegate onClickButtonRecordUpAction:sender];
    }
}


- (void)centerGestureAction:(UIGestureRecognizer *)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]] && _delegate && [_delegate respondsToSelector:@selector(centerTapGestureAction:)]) {
        [_delegate centerTapGestureAction:sender];
    }
    
    if ([sender isKindOfClass:[UIPanGestureRecognizer class]] && _delegate && [_delegate respondsToSelector:@selector(centerPanGestureAction:)]) {
        [_delegate centerPanGestureAction:sender];
    }
    
    if ([sender isKindOfClass:[UIPinchGestureRecognizer class]] && _delegate && [_delegate respondsToSelector:@selector(centerPinchGestureAction:)]) {
        [_delegate centerPinchGestureAction:sender];
    }
}

- (void)bottomGestureAction:(UIGestureRecognizer *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(viewBottomTouchDownAction:)]) {
        [_delegate viewBottomTouchDownAction:sender];
    }
}

@end
