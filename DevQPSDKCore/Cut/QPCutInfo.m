//
//  QPCutInfo.m
//  QupaiSDK
//
//  Created by lyle on 14-3-18.
//  Copyright (c) 2014年 lyle. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "QPCutInfo.h"

@implementation QPCutInfo

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
        _cutMaxDuration = 8.0;
        _cutMinDuration = 2.0;
        _playTime = -1.0;
        return self;
    }
    return nil;
}

- (id)initWithLocalIdentifier:(NSString *)localIdentifier
{
    self = [self initWithURL:nil];
    _localIdentifier = localIdentifier;
    return self;
}

- (void)setupWithAVAsset:(AVAsset *)asset
{
    _asset = asset;
    _videoDuration = CMTimeGetSeconds(_asset.duration);
    _startTime = 0.0;
    _endTime = MIN(_videoDuration, _cutMaxDuration);
}

- (NSInteger)thumbnailCount
{
    if (_cutMaxDuration > 2.0) {
        return ceilf(_videoDuration/(_cutMaxDuration/8.0));
    }
    return ceilf(_videoDuration);
}

@end
