//
//  EffectLoadMoreMusicCell.m
//  qupai
//
//  Created by yly on 14/12/23.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import "QPEffectLoadMoreCell.h"

@implementation QPEffectLoadMoreCell

- (void)awakeFromNib {
    // Initialization code
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        self.labelName.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
}

@end
