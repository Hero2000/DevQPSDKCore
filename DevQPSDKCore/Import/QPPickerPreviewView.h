//
//  QPPickerPreviewView.h
//  QPSDK
//
//  Created by LYZ on 16/5/6.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QPPickerPreviewViewDelegate <NSObject>

- (void)onClickButtonCloseAction:(UIButton *)sender;
- (void)onClickButtonFinishAction:(UIButton *)sender;

- (void)onClickButtonSelectAction:(UIButton *)sender;

@end

@interface QPPickerPreviewView : UIView

@property (nonatomic, strong) UIView *viewTop;
@property (nonatomic, strong) UIButton *buttonClose;
@property (nonatomic, strong) UIButton *buttonFinish;
@property (nonatomic, strong) UILabel *labelTopTitle;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *viewCenter;
@property (nonatomic, strong) UIView *viewPlayer;
@property (nonatomic, strong) UIButton *buttonSelect;

@property (nonatomic, strong) UIView *viewNotice;
@property (nonatomic, strong) UILabel *labbelNotice;
@property (nonatomic, strong) UIView *viewPermission;

@property (nonatomic, strong) UIView *viewBottom;
@property (nonatomic, strong) UILabel *labelVideoCount;

@property (nonatomic, strong) UILabel *oneLineNoticeLabel;
@property (nonatomic, strong) UILabel *twoLineNoticeLabel;
@property (nonatomic, strong) UILabel *threeLineNoticeLabel;

@property (nonatomic, weak) id<QPPickerPreviewViewDelegate> delegate;

@end
