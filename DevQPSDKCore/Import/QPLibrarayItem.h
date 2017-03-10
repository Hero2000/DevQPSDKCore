//
//  LibrarayItem.h
//  duanqu2
//
//  Created by lyle on 13-11-28.
//  Copyright (c) 2013年 duanqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, QPLibrarayItemType){
    QPLibrarayItemTypeNone,
    QPLibrarayItemTypeHighFrameRate,
    QPLibrarayItemTypeTimelapse,
};

@interface QPLibrarayItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic) long long createtime;//毫秒级别

@property (nonatomic, assign) QPLibrarayItemType type;
@property (nonatomic, strong) AVAsset *photoAsset;/* iOS8 慢动作的asset */

+ (id)createFromAsset:(ALAsset *)asset;

- (NSString *)formateDuration;
- (AVAsset *)asset;
@end

