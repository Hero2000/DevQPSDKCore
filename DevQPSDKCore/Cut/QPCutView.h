//
//  QPCutView.h
//  QPSDK
//
//  Created by LYZ on 16/5/6.
//  Copyright © 2016年 danqoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QPCutViewDelegate <NSObject>

- (void)onClickButtonBackAction:(UIButton *)sender;
- (void)onClickButtonNextAction:(UIButton *)sender;
- (void)onClickButtonCutAction:(UIButton *)sender;

@end

@interface QPCutView : UIView

@property (nonatomic, strong) UIView *viewTop;
@property (nonatomic, strong) UIButton *buttonBack;
@property (nonatomic, strong) UIButton *buttonNext;
@property (nonatomic, strong) UIActivityIndicatorView *activityNext;

@property (nonatomic, strong) UIView *viewCenter;
@property (nonatomic, strong) UIScrollView *scrollViewPlayer;
@property (nonatomic, strong) UIImageView *imageViewPlayFlag;
@property (nonatomic, strong) UIButton *buttonCut;

@property (nonatomic, strong) UIView *viewBottom;
@property (nonatomic, strong) UIView *viewCutInfo;
@property (nonatomic, strong) UILabel *labelCutLeft;
@property (nonatomic, strong) UILabel *labelCutMiddle;
@property (nonatomic, strong) UILabel *labelCutRight;
@property (nonatomic, strong) UIView *viewProgress;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) id<QPCutViewDelegate> delegate;

@end
