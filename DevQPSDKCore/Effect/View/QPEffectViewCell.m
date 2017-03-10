//
//  QPEffectViewCell.m
//  QupaiSDK
//
//  Created by yly on 15/6/17.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPEffectViewCell.h"
#import "QupaiSDK.h"
@implementation QPEffectViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        _nameLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    
    _imageViewFrame.layer.masksToBounds = YES;
    _imageViewFrame.layer.cornerRadius = 35;
    
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.layer.cornerRadius = 35;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    _nameLabel.textColor = selected ? [QupaiSDK shared].tintColor : RGB(159, 159, 159);
    _nameLabel.textColor = selected ? [QupaiSDK shared].tintColor : [UIColor blackColor];
    
    if ([_nameLabel.text isEqualToString:@"原片"]) {
        _imageViewFrame.hidden = YES;
        if (selected) {
            [_iconImageView setImage:[QPImage imageNamed:@"mv_sample_b_on"]];
        }else {
            [_iconImageView setImage:[QPImage imageNamed:@"mv_sample_b"]];
        }
    }else{
        _imageViewFrame.hidden = !selected;
    }

    
}

@end
