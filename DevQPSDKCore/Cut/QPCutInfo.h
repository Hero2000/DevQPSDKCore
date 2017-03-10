//
//  QPCutInfo.h
//  QupaiSDK
//
//  Created by lyle on 14-3-18.
//  Copyright (c) 2014年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>

//NSString * const QupaiCutVideoFinishNotification = @"QupaiCutVideoFinishNotification";
//NSString * const QupaiCutVideoCancelNotification = @"QupaiCutVideoCancelNotification";

@class AVAsset;

@interface QPCutInfo : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *cutUrl;
@property (nonatomic, assign) CGFloat videoDuration;
@property (nonatomic, assign) CGFloat cutMaxDuration;
@property (nonatomic, assign) CGFloat cutMinDuration;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, assign) CGFloat offsetTime;
@property (nonatomic, assign) CGFloat playTime;
@property (nonatomic, assign) NSInteger thumbnailCount;
@property (nonatomic, assign) NSInteger dragRight;
@property (nonatomic, strong) NSString *localIdentifier;
@property (nonatomic, strong) AVAsset *asset;

- (id)initWithURL:(NSURL *)url;
- (id)initWithLocalIdentifier:(NSString *)localIdentifier;
- (void)setupWithAVAsset:(AVAsset *)asset;

@end
