//
//  LibrarayItem.m
//  duanqu2
//
//  Created by lyle on 13-11-28.
//  Copyright (c) 2013年 duanqu. All rights reserved.
//

#import "QPLibrarayItem.h"

@implementation QPLibrarayItem

+ (id)createFromAsset:(ALAsset *)asset
{
    QPLibrarayItem *li = [[QPLibrarayItem alloc] init];
 
    li.image = [UIImage imageWithCGImage:asset.thumbnail];
    li.duration = [[asset valueForProperty:ALAssetPropertyDuration] floatValue];
    NSDictionary *dic = [asset valueForProperty:ALAssetPropertyURLs];
    if (dic) {
        li.url = dic[dic.allKeys[0]];
    }
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    li.createtime = [date timeIntervalSince1970] * 1000;
    
    return li;
}

- (NSString *)formateDuration
{
    NSInteger duration = (int)(_duration + 0.4999);
    return [NSString stringWithFormat:@"%02zd:%02zd", duration/60, duration%60];
}

- (AVAsset *)asset
{
    if (_type == QPLibrarayItemTypeHighFrameRate) {
        return _photoAsset;
    }
    return [AVAsset assetWithURL:_url];
}

@end
