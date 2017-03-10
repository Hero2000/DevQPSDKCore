//
//  QPEffectMusicManager.m
//  DevQPSDKCore
//
//  Created by Worthy on 16/8/29.
//  Copyright © 2016年 LYZ. All rights reserved.
//

#import "QPEffectMusicManager.h"


@implementation QPEffectMusicManager

- (NSMutableArray *)createMusic
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:20];
    
    if(QupaiSDK.shared.enableMoreMusic){
        QPEffectMusic *effect = [[QPEffectMusic alloc] init];
        effect.name = @"更多音乐";
        effect.eid = INT_MAX;
        effect.icon = [[QPBundle mainBundle] pathForResource:@"edit_ico_more@2x" ofType:@"png"];
        effect.musicName = nil;
        [array addObject:effect];
    }
    {
        QPEffectMusic *effect = [[QPEffectMusic alloc] init];
        effect.name = @"原音";
        effect.eid = 0;
        effect.icon = [[QPBundle mainBundle] pathForResource:@"music_0@2x" ofType:@"png"];
        effect.musicName = nil;
        [array addObject:effect];
    }
    
    if ([QupaiSDK.shared.delegte respondsToSelector:@selector(qupaiSDKMusics:)]) {
        NSArray *more = [QupaiSDK.shared.delegte qupaiSDKMusics:QupaiSDK.shared];
        [array addObjectsFromArray:more];
    }
    return array;
}
@end
