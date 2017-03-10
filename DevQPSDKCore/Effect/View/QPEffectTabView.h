//
//  EffectTabArrowLine.h
//  qupai
//
//  Created by yly on 14/11/12.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol QPEffectTabViewDelegate <NSObject>

- (void)tabViewDidSelectIndex:(NSInteger)index;

@end

@interface QPEffectTabView : UIView

@property (nonatomic, weak) id<QPEffectTabViewDelegate> delegate;

@property (nonatomic, assign) CGFloat fromX;
@property (nonatomic, assign) CGFloat toX;
@property (nonatomic, strong) NSArray *tabs;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIButton *selectedButton;
- (void)selectIndex:(NSInteger)index withAnimation:(BOOL)animation;

@end
