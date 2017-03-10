//
//  QPEffect.m
//  QupaiSDK
//
//  Created by yly on 15/6/18.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPEffect.h"

@implementation QPEffect

@synthesize description = _description;

+(JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"eid":@"id"}];
}

+(BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

- (BOOL)isMore {
    return _eid == INT_MAX;
}

- (BOOL)isEmpty {
    return _eid == 0;
}

+ (NSString *)storageDirectoryWithEffectType:(QPEffectType)type {
    
    NSString *path = @"QPRes/pasterRes";
    switch (type) {
        case QPEffectTypeMV:
            path = @"QPRes/mvRes";
            break;
        case QPEffectTypeFilter:
            path = @"QPRes/filterRes";
            break;
        case QPEffectTypeMusic:
            path = @"QPRes/musicRes";
        default:
            break;
    }
    return path;
}


@end
