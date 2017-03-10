//
//  QPEffectView.m
//  QPSDK
//
//  Created by LYZ on 16/4/27.
//  Copyright © 2016年 danqoo. All rights reserved.
//

#import "QPEffectView.h"
#import "QPImage.h"
#import "QPEffectTabView.h"

#define kViewTopHeight 44
#define kButtonViewTopWeight 54
#define kActivityIndicatorWeight 37

#define kViewCenterNextTipHeight 34

#define kViewBottomViewtapHeight 42

#define kViewCenterViewMixHeight 32

#define kCollectionViewHeight 100

@interface QPEffectView() <QPEffectTabViewDelegate>

@end

@implementation QPEffectView 

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupSubViews];
    }
    
    return self;
}

- (void)setupSubViews {
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self setupTopSubViews];
    
    [self setupCenterSubViews];
    
    [self setupBottomSubViews];
    
    [self setupViewMixSubViews];
    
}

#pragma mark UI

// top
- (void)setupTopSubViews {
    
    self.viewTop = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, ScreenWidth, kViewTopHeight))];
    self.viewTop.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewTop];
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.viewTop.bounds];
    label.text = @"编辑视频";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17.f];
    [self.viewTop addSubview:label];
    
    self.buttonClose = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.buttonClose setImage:[QPImage imageNamed:@"record_ico_back.png"] forState:(UIControlStateNormal)];
    self.buttonClose.frame = CGRectMake(0, 0, kButtonViewTopWeight, kViewTopHeight - 4);
    [self.buttonClose addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewTop addSubview:self.buttonClose];
    
    self.buttonFinish = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonFinish.frame = CGRectMake(CGRectGetWidth(self.viewTop.frame) - kButtonViewTopWeight, 0, kButtonViewTopWeight, kViewTopHeight - 4);
    [self.buttonFinish setImage:[QPImage imageNamed:@"record_ico_next.png"] forState:(UIControlStateNormal)];
    [self.buttonFinish addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewTop addSubview:self.buttonFinish];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    self.activityIndicator.frame = CGRectMake(CGRectGetWidth(self.viewTop.frame) - 9 - kActivityIndicatorWeight, 0, kActivityIndicatorWeight, kViewTopHeight - 7);
    self.activityIndicator.hidesWhenStopped = YES;
    [self.viewTop addSubview:self.activityIndicator];
    self.activityIndicator.hidden = YES;
    
}


// centerView
- (void)setupCenterSubViews {
    
    self.viewCenter = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewTop.frame), ScreenWidth, ScreenWidth))];
    self.viewCenter.backgroundColor = [UIColor blackColor];
    [self addSubview:self.viewCenter];
    
    self.viewVideoContainer = [[UIView alloc] initWithFrame: self.viewCenter.bounds];
    self.viewVideoContainer.backgroundColor = [UIColor blackColor];
    [self.viewCenter addSubview:self.viewVideoContainer];
    
    self.viewNextTip = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.viewCenter.frame), kViewCenterNextTipHeight))];
    [self.viewCenter addSubview:self.viewNextTip];
    UILabel *nextTipLabel = [[UILabel alloc] initWithFrame: self.viewNextTip.bounds];
    nextTipLabel.text = @"视频已保存";
    nextTipLabel.textColor = [UIColor whiteColor];
    nextTipLabel.font = [UIFont systemFontOfSize:17.f];
    nextTipLabel.textAlignment = NSTextAlignmentCenter;
    [self.viewNextTip addSubview:nextTipLabel];
    
    self.viewNextTip.hidden = YES;
    
    self.buttonPlayOrPause = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonPlayOrPause.backgroundColor = [UIColor clearColor];
    self.buttonPlayOrPause.frame = self.viewCenter.bounds;
    [self.buttonPlayOrPause addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewCenter addSubview:self.buttonPlayOrPause];
    
    self.labelVideoTime = [[UILabel alloc] initWithFrame:(CGRectMake(CGRectGetWidth(self.viewCenter.frame) - 16 - 54, 20, 54, 21))];
    self.labelVideoTime.textAlignment = NSTextAlignmentLeft;
    self.labelVideoTime.text = @"00:00";
    self.labelVideoTime.textColor = [UIColor redColor];
    self.labelVideoTime.font = [UIFont systemFontOfSize:17.f];
    [self.viewCenter addSubview:self.labelVideoTime];
    
    self.labelVideoTime.hidden = YES;
    
}


// bottomView
- (void)setupBottomSubViews {
    
    self.viewBottom = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewCenter.frame), ScreenWidth, ScreenHeight - CGRectGetMaxY(self.viewCenter.frame)))];
    self.viewBottom.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewBottom];
    
    self.viewEffect = [[UIView alloc] initWithFrame:self.viewBottom.bounds];
    [self.viewBottom addSubview:self.viewEffect];
    
    [self setupBottomTabViews];

}

- (void)setupBottomTabViews {
    
    self.viewTab = [[QPEffectTabView alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.viewEffect.frame), 42))];
    self.viewTab.backgroundColor = [UIColor whiteColor];
    self.viewTab.delegate = self;
    [self.viewEffect addSubview:self.viewTab];
    
    
    self.viewTab.tabs = @[@"滤镜",  @"音乐"];
    
//    self.buttonFilter = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    self.buttonFilter.frame = CGRectMake(0, 10, 63, 32);
//    [self.buttonFilter setTitle:@"滤镜" forState:(UIControlStateNormal)];
//    self.buttonFilter.titleLabel.font = [UIFont systemFontOfSize:15.f];
//    [self.buttonFilter setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
//    [self.buttonFilter addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
//    [self.viewTab addSubview:self.buttonFilter];
//    
//    
//    
//    self.buttonMV = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    self.buttonMV.frame = CGRectMake(CGRectGetMidX(self.viewTab.frame)- 8 - 50, 10, 63, 32);
//    [self.buttonMV setTitle:@"MV" forState:(UIControlStateNormal)];
//    self.buttonMV.titleLabel.font = [UIFont systemFontOfSize:15.f];
//    [self.buttonMV setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
//    [self.buttonMV addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
//    [self.viewTab addSubview:self.buttonMV];
//    
//    
//    
//    self.buttonMusic = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    self.buttonMusic.frame = CGRectMake(CGRectGetWidth(self.viewTab.frame) - 8 - 100, 10, 100, 32);
//    [self.buttonMusic setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
//    self.buttonMusic.titleLabel.font = [UIFont systemFontOfSize:15.f];
//    [self.buttonMusic setTitle:@"音乐" forState:(UIControlStateNormal)];
//    self.buttonMusic.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0);
//    
//    [self.buttonMusic setImage:[QPImage imageNamed:@"edit_ico_music.png"] forState:(UIControlStateNormal)];
//    self.buttonMusic.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
//    [self.buttonMusic addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
//    [self.viewTab addSubview:self.buttonMusic];
    
    [self setupCollectionView];
}

- (void)setupCollectionView {
    
    UIView *BgView = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewTab.frame), ScreenWidth, CGRectGetHeight(self.viewEffect.frame) - CGRectGetMaxY(self.viewTab.frame)))];
    BgView.backgroundColor = RGB(212, 212, 212);
    [self.viewEffect addSubview:BgView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(70, 86);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
    self.collectionView = [[UICollectionView alloc]  initWithFrame:(CGRectMake(0, (CGRectGetHeight(BgView.frame) - kCollectionViewHeight) / 2, ScreenWidth, kCollectionViewHeight)) collectionViewLayout:layout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [BgView addSubview:self.collectionView];
}


// viewMix
- (void)setupViewMixSubViews {
    
    self.viewMix = [[UIView alloc] initWithFrame:(CGRectMake(3, CGRectGetMaxY(self.viewCenter.frame) - 2 - kViewCenterViewMixHeight, CGRectGetWidth(self.viewCenter.frame) - 6, kViewCenterViewMixHeight))];
    [self addSubview:self.viewMix];
    
    UIImageView *viewMixImage = [[UIImageView alloc] initWithFrame:self.viewMix.bounds];
    viewMixImage.image = [QPImage imageNamed:@"record_levelbase_bg.png"];
    [self.viewMix addSubview:viewMixImage];
    
    self.labelMixLeft = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 45, CGRectGetHeight(self.viewMix.frame)))];
    self.labelMixLeft.text = @"音乐";
    self.labelMixLeft.textColor = RGB(2, 204, 269);
    self.labelMixLeft.font = [UIFont systemFontOfSize:11.f];
    self.labelMixLeft.textAlignment = NSTextAlignmentCenter;
    [self.viewMix addSubview:self.labelMixLeft];
    
    self.labelMixRight = [[UILabel alloc] initWithFrame:(CGRectMake(CGRectGetWidth(self.viewMix.frame) - 45, 0, 45, CGRectGetHeight(self.viewMix.frame)))];
    self.labelMixRight.text = @"原音";
    self.labelMixRight.textColor = RGB(255, 204, 2);
    self.labelMixRight.font = [UIFont systemFontOfSize:11.f];
    self.labelMixRight.textAlignment = NSTextAlignmentCenter;
    [self.viewMix addSubview:self.labelMixRight];
    
    self.sliderMix = [[UISlider alloc] initWithFrame:(CGRectMake(CGRectGetMaxX(self.labelMixLeft.frame), 0, CGRectGetMinX(self.labelMixRight.frame) - CGRectGetMaxX(self.labelMixLeft.frame), 100))];
    self.sliderMix.center = CGPointMake(self.sliderMix.center.x, CGRectGetHeight(self.viewMix.frame) / 2);
    [self.sliderMix addTarget:self action:@selector(sliderClickAction:) forControlEvents:(UIControlEventTouchUpInside)];
    self.sliderMix.value = 0.5;
    self.sliderMix.minimumTrackTintColor = RGB(2, 204, 269);
    self.sliderMix.maximumTrackTintColor = RGB(255, 204, 2);
    [self.viewMix addSubview:self.sliderMix];
}


-(void)layoutSubviews {
    [super layoutSubviews];
    self.gpuImageView.center = CGPointMake(CGRectGetWidth(self.viewCenter.bounds)/2, (CGRectGetHeight(self.viewCenter.bounds)/2));
}

#pragma mark Action

- (void)buttonAction:(UIButton *)sender {
    
    if ([sender isEqual:self.buttonClose] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonCloseAction:)]) {
        [_delegate onClickButtonCloseAction:sender];
    }
    
    if ([sender isEqual:self.buttonFinish] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonFinishAction:)]) {
        [_delegate onClickButtonFinishAction:sender];
    }
    
    if ([sender isEqual:self.buttonPlayOrPause] && _delegate && [_delegate respondsToSelector:@selector(onCLickButtonPlayOrPauseAction:)]) {
        [_delegate onCLickButtonPlayOrPauseAction:sender];
    }
    
    
    if ([sender isEqual:self.buttonFilter] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonFilterAction:)]) {
        [_delegate onClickButtonFilterAction:sender];
    }
    
    if ([sender isEqual:self.buttonMV] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonMVAction:)]) {
        [_delegate onClickButtonMVAction:sender];
    }
    
    if ([sender isEqual:self.buttonMusic] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonMusicAction:)]) {
        [_delegate onClickButtonMusicAction:sender];
    }
    
}

- (void)sliderClickAction:(UISlider *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClickSliderAction:)]) {
        [_delegate onClickSliderAction:sender];
    }
}

#pragma mark - tab view delegate

-(void)tabViewDidSelectIndex:(NSInteger)index {
    UIButton *button = self.viewTab.selectedButton;
    if (index == 0) {
        if ([_delegate respondsToSelector:@selector(onClickButtonFilterAction:)]) {
            [_delegate onClickButtonFilterAction:button];
        }
    }else {
        if ([_delegate respondsToSelector:@selector(onClickButtonMusicAction:)]) {
            [_delegate onClickButtonMusicAction:button];
        }
    }
}

@end
