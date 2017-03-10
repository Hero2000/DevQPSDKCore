//
//  QPSDKConfig.m
//  QupaiSDK
//
//  Created by yly on 15/6/23.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPSDKConfig.h"

@implementation QPSDKConfig

+ (CGSize)videoSize
{
    return CGSizeMake(640, 640);
}

+ (BOOL)is35
{
    //   320*480
    return ScreenHeight == 480;
}

+ (BOOL)is40
{
    //    320x568
    return ScreenHeight == 568;
}

+ (BOOL)is47
{
    //    375x667
    return ScreenHeight == 667;
}

+ (BOOL)is55
{
    //    414x736
    return ScreenHeight == 736;
}

+ (BOOL)isBigBig
{
    return [self is47] || [self is55];
}
+ (BOOL)isBig40
{
    return ScreenHeight >= 568;
}
@end
