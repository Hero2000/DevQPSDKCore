//
//  QPEffectMVManager.m
//  DevQPSDKCore
//
//  Created by Worthy on 16/8/29.
//  Copyright © 2016年 LYZ. All rights reserved.
//

#import "QPEffectMVManager.h"

@interface QPEffectMVManager ()
@property (nonatomic, strong) NSMutableArray *customMVs;
@property (nonatomic, strong) NSMutableArray *bundleMVs;
@property (nonatomic, strong) NSMutableArray *localMVs;
@end

@implementation QPEffectMVManager

#pragma mark - load

- (NSMutableArray *)loadEffectMVs {
    _mvs = [NSMutableArray arrayWithCapacity:4];
    _customMVs = [NSMutableArray arrayWithCapacity:4];
    _bundleMVs = [NSMutableArray arrayWithCapacity:4];
    _localMVs = [NSMutableArray arrayWithCapacity:4];
    
    {
        QPEffectMV *effect = [[QPEffectMV alloc] init];
        effect.name = @"更多";
        effect.eid = INT_MAX;
        effect.icon = [[QPBundle mainBundle] pathForResource:@"edit_ico_more@2x" ofType:@"png"];
        [_customMVs addObject:effect];
    }
    {
        QPEffectMV *effect = [[QPEffectMV alloc] init];
        effect.name = @"原片";
        effect.eid = 0;
        effect.icon = [[QPBundle mainBundle] pathForResource:@"mv_sample_b@2x" ofType:@"png"];
        [_customMVs addObject:effect];
        
    }
    [_mvs addObjectsFromArray:_customMVs];
    
    [_bundleMVs addObjectsFromArray:[self loadBundleEffectMVs]];
    if (_bundleMVs.count) {
        [_mvs addObjectsFromArray:_bundleMVs];
    }
    
    [_localMVs addObjectsFromArray:[self loadLocalEffectMVs]];
    if (_localMVs.count) {
        [_mvs addObjectsFromArray:_localMVs];
    }
    return _mvs;
}

- (NSArray *)loadBundleEffectMVs {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
    NSString *configPath = [[QPBundle mainBundle] pathForResource:@"mv" ofType:@"json"];
    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingAllowFragments error:nil];
    NSArray *items = dic[@"filter"];
    NSString *baseDir = [[QPBundle mainBundle] bundlePath];
    for (NSDictionary *item in items) {
        QPEffectMV *effect = [[QPEffectMV alloc] init];
        effect.resourceLocalUrl = [baseDir stringByAppendingPathComponent:item[@"resourceUrl"]];
        effect.name = item[@"name"];
        effect.icon = [effect resourceLocalIconPath];
        effect.eid = [item[@"id"] integerValue];
        [array addObject:effect];
    }
    return array;
}

- (NSArray *)loadLocalEffectMVs {
    NSString *basePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *mvDir = [QPEffect storageDirectoryWithEffectType:QPEffectTypeMV];
    NSString *mvPath = [basePath stringByAppendingPathComponent:mvDir];
    if([[NSFileManager defaultManager] fileExistsAtPath:mvPath]){
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
        NSError *error = nil;
        NSArray *subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mvPath error:&error];
        if (error) return nil;
        for (NSString *subPath in subPaths) {
            NSArray *components = [subPath componentsSeparatedByString:@"-"];
            if (components.count != 2) continue;
            QPEffectMV *effect = [[QPEffectMV alloc] init];
            effect.resourceLocalUrl = [mvPath stringByAppendingPathComponent:subPath];
            effect.name = components[1];
            effect.icon = [effect resourceLocalIconPath];
            effect.eid = [components[0] integerValue];
            [array addObject:effect];
        }
        return array;
    }
    return nil;
}

#pragma mark - getter

-(NSMutableArray *)localEffectMVs {
    return _localMVs;
}

-(NSMutableArray *)bundleEffectMVs {
    return _bundleMVs;
}

#pragma mark - manage

- (void)refresh {
    [_mvs removeAllObjects];
    [_mvs addObjectsFromArray:_customMVs];
    [_mvs addObjectsFromArray:_bundleMVs];
    _localMVs = [NSMutableArray arrayWithArray:[self loadLocalEffectMVs]];
    [_mvs addObjectsFromArray:_localMVs];
}

-(void)deleteEffectMVByID:(NSUInteger)eid {
    for (QPEffectMV *mv in _localMVs) {
        if (mv.eid == eid) {
            [self deleteEffectMV:mv];
            break;
        }
    }
}

- (void)deleteEffectMV:(QPEffectMV *)mv {
    NSString *localPath = mv.resourceLocalUrl;
    if([[NSFileManager defaultManager] fileExistsAtPath:localPath]){
        [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
    }
    [self refresh];
}

@end


