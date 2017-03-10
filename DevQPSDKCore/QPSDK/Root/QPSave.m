//
//  QPSave.m
//  QupaiSDK
//
//  Created by yly on 15/6/29.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPSave.h"

static NSString * kQupaiSDKKey = @"__qupai_sdk_config_key__";

@implementation QPSave

+ (instancetype)shared
{
    static QPSave *_qpSave = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kQupaiSDKKey];
        _qpSave = [[QPSave alloc] initWithDictionary:dic];
    });
    return _qpSave;
}

- (void)save
{
    NSDictionary *dic = [self toDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kQupaiSDKKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
