//
//  DraftsCell.m
//  duanqu2
//
//  Created by lyle on 14-2-26.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import "QPPickerPreviewCell.h"

@implementation QPPickerPreviewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5.0;
    
    self.imageViewIcon = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.imageViewIcon];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetHeight(self.contentView.frame) - 17, CGRectGetWidth(self.contentView.frame), 17))];
    bottomView.backgroundColor = RGB(59, 59, 59);
    [self.contentView addSubview:bottomView];
    
    self.imageViewFlag = [[UIImageView alloc] initWithFrame:(CGRectMake(6, CGRectGetHeight(self.contentView.frame) - 17, 13, 17))];
    self.imageViewFlag.image = [QPImage imageNamed:@"camera.png"];
    self.imageViewFlag.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.imageViewFlag];
    
    self.labelDuration = [[UILabel alloc] initWithFrame:(CGRectMake(CGRectGetWidth(self.contentView.frame) - 42 - 4, CGRectGetMinY(self.imageViewFlag.frame), 42, CGRectGetHeight(self.imageViewFlag.frame)))];
    self.labelDuration.textColor = [UIColor whiteColor];
    self.labelDuration.font = [UIFont systemFontOfSize:14.f];
    self.labelDuration.text = @"0:00";
    [self.contentView addSubview:self.labelDuration];
    
    self.maskerImage = [[UIImageView alloc] initWithFrame: self.contentView.bounds];
    self.maskerImage.backgroundColor = RGBToColor(2, 212, 255, 0.5);
    [self.contentView addSubview:self.maskerImage];
    [self.maskerImage setHidden:YES];
}

- (void)awakeFromNib
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5.0;
//    if ([GlobalConfig isFour]) {
//        _viewBoard.frame = CGRectMake(0, 0, 85, 85);
//        _viewBg.frame = CGRectMake(2, 2, 81, 81);
//    }else{
//        _viewBoard.frame = CGRectMake(0, 0, 63, 63);
//        _viewBg.frame = CGRectMake(2, 2, 59, 59);
//    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.layer.borderWidth = 0;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    self.maskerImage.hidden = !selected;
}

//- (void)setVideo:(Video *)video
//{
//    _video = video;
//    if (_video.imageURL) {
//        _imageViewIcon.image = [UIImage imageWithContentsOfFile:_video.imageURL.path];
//    }else if(_video.imageLibrary){
//        _imageViewIcon.image = _video.imageLibrary;
//    }
//    NSInteger duration = video.type == VideoTypeDraftsEffect ? (int)(_video.duration + 0.4999) : (int)ceil(_video.duration);
//    _labelDuration.text = [NSString stringWithFormat:@"%02zd:%02zd",(int)duration/60, duration%60];
//    _imageViewFlag.image = [self imageForVideoSubtype:_video.subtype];
//}
//
//- (UIImage *)imageForVideoSubtype:(VideoSubtype)subtype
//{
//    if (subtype == VideoSubtypeHighFrameRate) {
//        return [UIImage imageNamed:@"ico_slowmotion"];
//    }else if (subtype == VideoSubtypeTimelapse) {
//        return [UIImage imageNamed:@"ico_delay"];
//    }
//    return [UIImage imageNamed:@"camera"];
//}

@end
