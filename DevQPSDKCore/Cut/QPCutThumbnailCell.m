//
//  QPCutThumbnailCell.m
//  QupaiSDK
//
//  Created by lyle on 14-3-17.
//  Copyright (c) 2014年 lyle. All rights reserved.
//

#import "QPCutThumbnailCell.h"

@implementation QPCutThumbnailCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageViewIcon = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:self.imageViewIcon];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    // Configure the view for the selected state
}

@end
