//
//  QPPickerPreviewView.m
//  QPSDK
//
//  Created by LYZ on 16/5/6.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import "QPPickerPreviewView.h"

#define kTopViewHeight 61

@implementation QPPickerPreviewView

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
    
    [self setupViewNotice];
    
    [self setupBottomViews];
    
}

- (void)setupTopViews {
    
    self.viewTop = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, ScreenWidth, kTopViewHeight))];
    self.viewTop.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.viewTop];
    
    self.buttonClose = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.buttonClose setImage:[QPImage imageNamed:@"record_ico_close.png"] forState:(UIControlStateNormal)];
    self.buttonClose.frame = CGRectMake(0, 0, 60, kTopViewHeight);
    [self.buttonClose addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewTop addSubview:self.buttonClose];
    
    self.buttonFinish = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonFinish.frame = CGRectMake(CGRectGetWidth(self.viewTop.frame) - 60, 0, 60, kTopViewHeight);
    [self.buttonFinish setImage:[QPImage imageNamed:@"input_ico_check.png"] forState:(UIControlStateNormal)];
    [self.buttonFinish addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewTop addSubview:self.buttonFinish];

    self.labelTopTitle = [[UILabel alloc] initWithFrame:self.viewTop.bounds];
    self.labelTopTitle.text = @"导入";
    self.labelTopTitle.textColor = [UIColor blackColor];
    self.labelTopTitle.textAlignment = NSTextAlignmentCenter;
    self.labelTopTitle.font = [UIFont systemFontOfSize:18.f];
    [self.viewTop addSubview:self.labelTopTitle];

}


- (void)setupCenterViews {
    
    self.viewCenter = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewTop.frame), ScreenWidth, ScreenWidth))];
    self.viewCenter.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewCenter];
    
    self.buttonSelect = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonSelect.frame = self.viewCenter.bounds;
    self.buttonSelect.backgroundColor = [UIColor clearColor];
    [self.buttonSelect addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewCenter addSubview:self.buttonSelect];
    
    self.viewPlayer = [[UIView alloc] initWithFrame: self.viewCenter.bounds];
    self.viewPlayer.backgroundColor = [UIColor clearColor];
    [self.viewCenter addSubview:self.viewPlayer];
    
    
    
}


- (void)setupViewNotice {
    
    self.viewNotice = [[UIView alloc] initWithFrame:(CGRectMake(0, kTopViewHeight + 123, ScreenWidth, 200))];
    self.viewNotice.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.viewNotice];
    
    self.viewPermission = [[UIView alloc] initWithFrame: self.viewNotice.bounds];
    self.viewPermission.backgroundColor = [UIColor clearColor];
    [self.viewNotice addSubview:self.viewPermission];
    
    UIImageView *libraryImage = [[UIImageView alloc] initWithImage:[QPImage imageNamed:@"library_perm_no_icon.png"]];
    libraryImage.frame = CGRectMake((CGRectGetWidth(self.viewPermission.frame) - 78) / 2, 11, 78, 78);
    [self.viewPermission addSubview:libraryImage];
    
    self.oneLineNoticeLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(libraryImage.frame) + 11, CGRectGetWidth(self.viewPermission.frame), 21))];
    self.oneLineNoticeLabel.text = @"趣拍无法访问视频";
    self.oneLineNoticeLabel.textColor = [UIColor whiteColor];
    self.oneLineNoticeLabel.textAlignment = NSTextAlignmentCenter;
    self.oneLineNoticeLabel.font = [UIFont systemFontOfSize:17.f];
    [self.viewPermission addSubview:self.oneLineNoticeLabel];
    
    self.twoLineNoticeLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.oneLineNoticeLabel.frame) + 6, CGRectGetWidth(self.viewPermission.frame), 21))];
    self.twoLineNoticeLabel.text = @"请前往 “设置-隐私-照片”";
    self.twoLineNoticeLabel.textColor = [UIColor whiteColor];
    self.twoLineNoticeLabel.textAlignment = NSTextAlignmentCenter;
    self.twoLineNoticeLabel.font = [UIFont systemFontOfSize:13.f];
    [self.viewPermission addSubview:self.twoLineNoticeLabel];
    
    self.threeLineNoticeLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.twoLineNoticeLabel.frame) + 6, CGRectGetWidth(self.viewPermission.frame), 21))];
    self.threeLineNoticeLabel.text = @"将趣拍设置为开启。";
    self.threeLineNoticeLabel.textColor = [UIColor whiteColor];
    self.threeLineNoticeLabel.textAlignment = NSTextAlignmentCenter;
    self.threeLineNoticeLabel.font = [UIFont systemFontOfSize:13.f];
    [self.viewPermission addSubview:self.threeLineNoticeLabel];
    
    [self.viewNotice setHidden:YES];
}


- (void)setupBottomViews {
    
    self.viewBottom = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(self.viewCenter.frame), ScreenWidth, ScreenHeight - CGRectGetMaxY(self.viewCenter.frame)))];
    self.viewBottom.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.viewBottom];
    
    [self setupCollectionView];
    
    self.labelVideoCount = [[UILabel alloc] initWithFrame:(CGRectMake(0, CGRectGetHeight(self.viewBottom.frame) - 30, CGRectGetWidth(self.viewBottom.frame), 30))];
    self.labelVideoCount.textAlignment = NSTextAlignmentCenter;
    self.labelVideoCount.font = [UIFont systemFontOfSize:13.f];
    self.labelVideoCount.textColor = [UIColor lightGrayColor];
    [self.viewBottom addSubview:self.labelVideoCount];
}

- (void)setupCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 80);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
    self.collectionView = [[UICollectionView alloc]  initWithFrame:(CGRectMake(0, (CGRectGetHeight(self.viewBottom.frame) - 80) / 2, ScreenWidth, 80)) collectionViewLayout:layout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.viewBottom addSubview:self.collectionView];
}

#pragma mark Action

- (void)buttonAction:(UIButton *)sender {
    
    if ([sender isEqual:self.buttonClose] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonCloseAction:)]) {
        [_delegate onClickButtonCloseAction:sender];
    }
    
    if ([sender isEqual:self.buttonFinish] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonFinishAction:)]) {
        [_delegate onClickButtonFinishAction:sender];
    }
    
    if ([sender isEqual:self.buttonSelect] && _delegate && [_delegate respondsToSelector:@selector(onClickButtonSelectAction:)]) {
        [_delegate onClickButtonSelectAction:sender];
    }
    
}

@end
