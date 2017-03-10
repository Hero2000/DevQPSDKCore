//
//  QPEffectFilterManager.m
//  DevQPSDKCore
//
//  Created by Worthy on 16/8/29.
//  Copyright © 2016年 LYZ. All rights reserved.
//

#import "QPEffectFilterManager.h"

@implementation QPEffectFilterManager

- (NSMutableArray *)createFilter
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
    QPEffectFilter *effect;
    
    effect = [[QPEffectFilter alloc] init];// clientID:0 name:@"原片" imageName:@"mv_sample_b.png"];
    effect.name = @"原片";
    effect.eid = 0;
    effect.icon = [[QPBundle mainBundle] pathForResource:@"mv_sample_b@2x" ofType:@"png"];
    [array addObject:effect];
    {
        NSString *configPath = [[QPBundle mainBundle] pathForResource:@"filter" ofType:@"json"];
        NSData *configData = [NSData dataWithContentsOfFile:configPath];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingAllowFragments error:nil];
        NSArray *items = dic[@"filter"];
        NSString *baseDir = [[QPBundle mainBundle] bundlePath];
        for (NSDictionary *item in items) {
            effect = [[QPEffectFilter alloc] init];
            effect.resourceLocalUrl = [baseDir stringByAppendingPathComponent:item[@"resourceUrl"]];
            effect.name   = item[@"name"];
            effect.icon = [effect.resourceLocalUrl stringByAppendingPathComponent:@"icon.png"];
            effect.eid = [item[@"id"] integerValue];
            [array addObject:effect];
        }
    }
    return array;
}
@end
