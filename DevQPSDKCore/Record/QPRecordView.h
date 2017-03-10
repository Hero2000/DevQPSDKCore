//
//  QPRecordView.h
//  QPSDK
//
//  Created by LYZ on 16/4/25.
//  Copyright © 2016年 danqoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QPPointProgress;

@protocol QPRecordViewDelegate <NSObject>

- (void)onClickButtonCloseAction:(UIButton *)sender;
- (void)onClickButtonPositionAction:(UIButton *)sender;
- (void)onCLickButtonTimeAction:(UIButton *)sender;
- (void)onClickButtonSkinAction:(UIButton *)sender;
- (void)onClickButtonLibraryAction:(UIButton *)sender;
- (void)onClickButtonRecordDownAction:(UIButton *)sender;
- (void)onClickButtonRecordUpAction:(UIButton *)sender;
- (void)onClickButtonFinishAction:(UIButton *)sender;

- (void)centerPinchGestureAction:(UIGestureRecognizer *)sender;
- (void)centerPanGestureAction:(UIGestureRecognizer *)sender;
- (void)centerTapGestureAction:(UIGestureRecognizer *)sender;

- (void)viewBottomTouchDownAction:(UIGestureRecognizer *)sender;

@end

@interface QPRecordView : UIView

-(instancetype)initWithFrame:(CGRect)frame videoSize:(CGSize)videoSize bottomPanelHeight:(CGFloat)height;

@property (nonatomic, strong) UIView *viewCenter;
@property (nonatomic, strong) QPPointProgress *pointProgress;
@property (nonatomic, strong) UIView *gpuImageView;
@property (nonatomic, strong) UIView *viewMask;
@property (nonatomic, strong) UILabel *labelOrientation;
@property (nonatomic, strong) UIButton *buttonPosition;
@property (nonatomic, strong) UIButton *buttonSkin;
@property (nonatomic, strong) UIView *viewFocusContent;
@property (nonatomic, strong) UIImageView *skinBgImage;
@property (nonatomic, strong) UIView *viewProgress;

@property (nonatomic, strong) UIView *viewSkin;
@property (nonatomic, strong) UISlider *sliderSkin;
@property (nonatomic, strong) UIButton *buttonTime;

@property (nonatomic, strong) UILabel *labelSkinRight;

@property (nonatomic, strong) UIView *viewScale;
@property (nonatomic, strong) UILabel *labelScale;

@property (nonatomic, strong) UIView *viewTop;
@property (nonatomic, strong) UIButton *buttonClose;
@property (nonatomic, strong) UIButton *buttonFinish;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIView *viewBottom;
@property (nonatomic, strong) UIButton *buttonRecord;
@property (nonatomic, strong) UIButton *buttonLibrary;

@property (nonatomic, strong) NSLayoutConstraint *constraintViewSkinVerticalSpace;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIView *viewTimeNotice;

@property (nonatomic, strong) UILabel *viewTimeNoticeTop;

@property (nonatomic, strong) UIView *viewTimeNoticeBottom;
@property (nonatomic, strong) UILabel *qupaiLogo;

@property (nonatomic, weak) id<QPRecordViewDelegate> delegate;

@end
