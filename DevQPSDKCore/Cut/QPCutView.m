//
//  QPCutView.m
//  QPSDK
//
//  Created by LYZ on 16/5/6.
//  Copyright © 2016年 danqoo. All rights reserved.
//

#import "QPCutView.h"
#import "QPImage.h"

#define kTopViewHeight 55
#define kScrollViewHeight 240


@implementation QPCutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self setupTopViews];
    
    [self setupCenterViews];
    
    [self setupBottomViews];
    
}

// topView
- (void)setupTopViews {
    
    self.viewTop = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, ScreenWidth, kTopViewHeight))];
    self.viewTop.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.viewTop];
    
    self.buttonBack = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.buttonBack setImage:[QPImage imageNamed:@"record_ico_back.png"] forState:(UIControlStateNormal)];
    self.buttonBack.frame = CGRectMake(4, 6, 58, kTopViewHeight - 6 - 5);
    [self.buttonBack addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewTop addSubview:self.buttonBack];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:self.viewTop.bounds];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = @"裁剪";
    [self.viewTop addSubview:nameLabel];
    
    self.buttonNext = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonNext.frame = CGRectMake(CGRectGetWidth(self.viewTop.frame) - 4 - 80, 16, 80, kTopViewHeight - 16 - 15);
    [self.buttonNext setImage:[QPImage imageNamed:@"record_ico_next.png"] forState:(UIControlStateNormal)];
    [self.buttonNext addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewTop addSubview:self.buttonNext];
    
    self.activityNext = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    self.activityNext.frame = CGRectMake(CGRectGetWidth(self.viewTop.frame) - 16 - 37, 9, 37, kTopViewHeight - 9 - 9);
    [self.viewTop addSubview:self.activityNext];
}



// centerView
- (void)setupCenterViews {
    
    self.viewCenter = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewTop.frame), ScreenWidth, ScreenWidth))];
    self.viewCenter.backgroundColor = [UIColor blackColor];
    [self addSubview:self.viewCenter];
    
    self.scrollViewPlayer = [[UIScrollView alloc] initWithFrame:(CGRectMake((ScreenWidth - kScrollViewHeight) / 2, (ScreenWidth - kScrollViewHeight) / 2, kScrollViewHeight, kScrollViewHeight))];
    self.scrollViewPlayer.backgroundColor = [UIColor blackColor];
    self.scrollViewPlayer.showsVerticalScrollIndicator = NO;
    self.scrollViewPlayer.showsHorizontalScrollIndicator = NO;
    [self.viewCenter addSubview:self.scrollViewPlayer];
    
    self.imageViewPlayFlag = [[UIImageView alloc] initWithFrame:(CGRectMake(13, CGRectGetHeight(self.viewCenter.frame) - 13 - 40, 40, 40))];
    [self.imageViewPlayFlag setImage:[QPImage imageNamed:@"ico_play.png"]];
    [self.viewCenter addSubview:self.imageViewPlayFlag];
    
    self.buttonCut = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonCut.frame = CGRectMake(CGRectGetWidth(self.viewCenter.frame) - 60, CGRectGetHeight(self.viewCenter.frame) - 60, 50, 50);
    [self.buttonCut addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewCenter addSubview:self.buttonCut];
    
    [self.buttonCut setImage:[QPImage imageNamed:@"edit_proportion.png"] forState:(UIControlStateNormal)];
    [self.buttonCut setImage:[QPImage imageNamed:@"edit_proportion_selected.png"] forState:(UIControlStateSelected)];
    
    [self.buttonCut setSelected:YES];
    
    
}


// bottomView
- (void)setupBottomViews {
    
    
    [self setupBottomCutInfoViews];
    
    [self setupBottomOtherViews];
    
}

- (void)setupBottomCutInfoViews {
    
    self.viewBottom = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewCenter.frame), ScreenWidth, ScreenHeight - CGRectGetMaxY(self.viewCenter.frame)))];
    self.viewBottom.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewBottom];
    
    self.viewCutInfo = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, ScreenWidth, 45))];
    self.viewCutInfo.backgroundColor = [UIColor whiteColor];
    [self.viewBottom addSubview:self.viewCutInfo];
    
    self.labelCutLeft = [[UILabel alloc] initWithFrame:(CGRectMake(10, 0, 48, CGRectGetHeight(self.viewCutInfo.frame)))];
    self.labelCutLeft.textColor = RGB(169, 169, 169);
    self.labelCutLeft.font = [UIFont boldSystemFontOfSize:14.f];
    self.labelCutLeft.textAlignment = NSTextAlignmentCenter;
    self.labelCutLeft.text = @"00:00";
    [self.viewCutInfo addSubview:self.labelCutLeft];
    
    self.labelCutMiddle = [[UILabel alloc] initWithFrame:(CGRectMake((CGRectGetWidth(self.viewCutInfo.frame) - 50) / 2, 0, 50, CGRectGetHeight(self.viewCutInfo.frame)))];
    self.labelCutMiddle.textColor = RGB(29, 211, 128);
    self.labelCutMiddle.font = [UIFont boldSystemFontOfSize:17.f];
    self.labelCutMiddle.textAlignment = NSTextAlignmentCenter;
    self.labelCutMiddle.text = @"00:00";
    [self.viewCutInfo addSubview:self.labelCutMiddle];
    
    self.labelCutRight = [[UILabel alloc] initWithFrame:(CGRectMake(CGRectGetWidth(self.viewCutInfo.frame) - 10 - 42, 0, 42, CGRectGetHeight(self.viewCutInfo.frame)))];
    self.labelCutRight.textColor = RGB(169, 169, 169);
    self.labelCutRight.font = [UIFont boldSystemFontOfSize:13.f];
    self.labelCutRight.textAlignment = NSTextAlignmentCenter;
    self.labelCutRight.text = @"00:00";
    [self.viewCutInfo addSubview:self.labelCutRight];
    
}

- (void)setupBottomOtherViews {
    
    self.viewProgress = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewCutInfo.frame), ScreenWidth, CGRectGetHeight(self.viewBottom.frame) - CGRectGetMaxY(self.viewCutInfo.frame) - 69))];
    self.viewProgress.backgroundColor = [UIColor whiteColor];
    [self.viewBottom addSubview:self.viewProgress];
    
    [self setupCollectionView];
    
    UILabel *pointLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewProgress.frame), ScreenWidth, CGRectGetHeight(self.viewBottom.frame) - CGRectGetMaxY(self.viewProgress.frame)))];
    pointLabel.text = @"拖动剪刀或缩略图裁剪视频";
    pointLabel.textColor = [UIColor lightGrayColor];
    pointLabel.font = [UIFont systemFontOfSize:14.f];
    pointLabel.textAlignment = NSTextAlignmentCenter;
    [self.viewBottom addSubview:pointLabel];
    
}


- (void)setupCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(50, 40);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc]  initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewCutInfo.frame) + 3, ScreenWidth, 40)) collectionViewLayout:layout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.viewBottom addSubview:self.collectionView];
}


#pragma mark Action

- (void)buttonAction:(UIButton *)sender {
    
    if ([sender isEqual:self.buttonBack] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonBackAction:)]) {
        [_delegate onClickButtonBackAction:sender];
    }
    
    if ([sender isEqual:self.buttonNext] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonNextAction:)]) {
        [_delegate onClickButtonNextAction:sender];
    }
    
    if ([sender isEqual:self.buttonCut] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonCutAction:)]) {
        
        
        [_delegate onClickButtonCutAction:sender];
    }
}

@end
