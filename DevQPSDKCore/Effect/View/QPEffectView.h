//
//  QPEffectView.h
//  QPSDK
//
//  Created by LYZ on 16/4/27.
//  Copyright © 2016年 danqoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QPEffectTabView;


@protocol QPEffectViewDelegate <NSObject>

- (void)onClickButtonCloseAction:(UIButton *)sender;
- (void)onClickButtonFinishAction:(UIButton *)sender;
- (void)onCLickButtonPlayOrPauseAction:(UIButton *)sender;

- (void)onClickButtonFilterAction:(UIButton *)sender;
- (void)onClickButtonMVAction:(UIButton *)sender;
- (void)onClickButtonMusicAction:(UIButton *)sender;

- (void)onClickSliderAction:(UISlider *)sender;

@end

@interface QPEffectView : UIView

@property (nonatomic, strong) UIView *viewTop;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *buttonClose;
@property (nonatomic, strong) UIButton *buttonFinish;

@property (nonatomic, strong) UIView *viewCenter;
@property (nonatomic, strong) UIView *viewVideoContainer;
@property (nonatomic, strong) UIView *gpuImageView;
@property (nonatomic, strong) UIView *viewNextTip;
@property (nonatomic, strong) UIButton *buttonPlayOrPause;

@property (nonatomic, strong) UIView *viewBottom;
@property (nonatomic, strong) UIView *viewEffect;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) QPEffectTabView *viewTab;
@property (nonatomic, strong) UIButton *buttonFilter;
@property (nonatomic, strong) UIButton *buttonMV;
@property (nonatomic, strong) UIButton *buttonMusic;

@property (nonatomic, strong) UIView *viewMix;
@property (nonatomic, strong) UISlider *sliderMix;
@property (nonatomic, strong) UILabel *labelMixLeft;
@property (nonatomic, strong) UILabel *labelMixRight;

@property (nonatomic, strong) UILabel *labelVideoTime;

@property (nonatomic, strong) NSLayoutConstraint *constraintViewCenterTop;
@property (nonatomic, strong) NSLayoutConstraint *constraintViewBottomTop;

@property (nonatomic, weak) id<QPEffectViewDelegate> delegate;

@end
