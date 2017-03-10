//
//  QPEffectMusic.m
//  QupaiSDK
//
//  Created by yly on 15/6/18.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPEffectMusic.h"

@implementation QPEffectMusic

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = QPEffectTypeMusic;
    }
    return self;
}

- (BOOL)isEmptyMusic
{
    return _musicName == nil;
}

@end
