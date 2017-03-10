//
//  EffectTabArrowLine.m
//  qupai
//
//  Created by yly on 14/11/12.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import "QPEffectTabView.h"

@interface QPEffectTabView ()

@property (nonatomic, strong) UIView *sliderView;
@end


@implementation QPEffectTabView


- (void)setFromX:(CGFloat)fromX
{
    _fromX = fromX;
}

- (void)setToX:(CGFloat)toX
{
    _toX = toX;
    [self setNeedsDisplay];
}

//- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
////    CGFloat w = CGRectGetWidth(self.bounds);
//    CGFloat h = CGRectGetHeight(self.bounds);
//    CGPoint points[2] = {};
//    points[0].x = _fromX;
//    points[0].y = h - 1.5;
//    points[1].x = _toX;
//    points[1].y = h - 1.5;
//    CGContextAddLines(context, points, sizeof(points)/sizeof(CGPoint));
//    CGContextSetLineWidth(context, 3.0);
//    CGContextSetStrokeColorWithColor(context, [QupaiSDK shared].tintColor.CGColor);
//    CGContextStrokePath(context);
//}


-(void)setTabs:(NSArray *)tabs {
    _tabs = tabs;
    [self setupTabView];
}

-(void)selectIndex:(NSInteger)index withAnimation:(BOOL)animation{
    _index = index;
    [self updateButtonStyle:_selectedButton selected:NO];
    _selectedButton = [self.buttons objectAtIndex:index];
    [self updateButtonStyle:_selectedButton selected:YES];
    CGRect labelFrame = _selectedButton.frame;
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            self.sliderView.frame = CGRectMake(labelFrame.origin.x, CGRectGetHeight(self.bounds) - 2, labelFrame.size.width, 2);
        }];
    }else {
        self.sliderView.frame = CGRectMake(labelFrame.origin.x, CGRectGetHeight(self.bounds) - 2, labelFrame.size.width, 2);
    }
}

#pragma mark - view

-(void)layoutSubviews {
    [super layoutSubviews];
    if (!self.buttons.count) {
        return;
    }
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat buttonWidth = width/self.buttons.count;
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        button.frame = CGRectMake(buttonWidth*i, 0, buttonWidth, height);
    }
    self.sliderView.frame = CGRectMake(buttonWidth*self.index, CGRectGetHeight(self.bounds) - 2, buttonWidth, 2);
}


- (void)setupTabView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.sliderView = [[UIView alloc] init];
    self.sliderView.backgroundColor = [QupaiSDK shared].tintColor;
    [self addSubview:self.sliderView];
    self.buttons = [NSMutableArray array];
    for (int i = 0; i < self.tabs.count; i++) {
        NSString *tab = self.tabs[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitle:tab forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttons addObject:button];
    }
    
}


#pragma mark - action

- (void)buttonClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    [self selectIndex:index withAnimation:YES];
    [self.delegate tabViewDidSelectIndex:index];
    
    
}

- (void)updateButtonStyle:(UIButton *)button selected:(BOOL)selected {
    if (selected) {
        [button setTitleColor:[QupaiSDK shared].tintColor forState:UIControlStateNormal];
    }else {
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}


@end
