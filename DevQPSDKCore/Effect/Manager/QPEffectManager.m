//
//  QPEffectManager.m
//  QupaiSDK
//
//  Created by yly on 15/6/18.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPEffectManager.h"
#import "QPEffectMusicManager.h"
#import "QPEffectMVManager.h"
#import "QPEffectFilterManager.h"
#import "QPEffectDownManager.h"

@interface QPEffectManager () <QPEffectDownManagerDelegate>
@property (nonatomic, strong) QPEffectMusicManager *musicManager;
@property (nonatomic, strong) QPEffectMVManager *mvManager;
@property (nonatomic, strong) QPEffectFilterManager *filterManager;
@property (nonatomic, strong) QPEffectDownManager *downManager;
@end


@implementation QPEffectManager
{
    NSMutableArray *_arrayMusic;
    NSMutableArray *_arrayFilter;
    NSMutableArray *_arrayMV;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _arrayFilter = [self.filterManager createFilter];
        _arrayMusic  = [self.musicManager createMusic];
        _arrayMV = [self.mvManager loadEffectMVs];
        return self;
    }
    return nil;
}

+ (QPEffectManager *)sharedManager {
    static dispatch_once_t once;
    static QPEffectManager *manager = nil;
    
    dispatch_once(&once,^{
        manager = [[QPEffectManager alloc] init];
    });
    return manager;
}

- (NSArray *)arrayByType:(QPEffectType)type
{
    if (type == QPEffectTypeFilter) {
        return _arrayFilter;
    }else if(type == QPEffectTypeMV){
        return _arrayMV;
    }else if(type == QPEffectTypeMusic){
        return _arrayMusic;
    }
    return nil;
}

- (NSUInteger)effectCountByType:(QPEffectType)type
{
    NSArray *array = [self arrayByType:type];
    return array.count;
}

- (QPEffect *)effectAtIndex:(NSUInteger)index type:(QPEffectType)type
{
    NSArray *array = [self arrayByType:type];
    if (index > array.count - 1) {
        return nil;
    }
    return array[index];
}

- (QPEffect *)effectByID:(NSUInteger)eid type:(QPEffectType)type
{
    NSArray *array = [self arrayByType:type];
    for (QPEffect *e in array) {
        if (e.eid == eid) {
            return e;
        }
    }
    return nil;
}

- (NSUInteger)effectIndexByID:(NSUInteger)eid type:(QPEffectType)type
{
    NSArray *array = [self arrayByType:type];
    __block NSUInteger index = 0;
    [array enumerateObjectsUsingBlock:^(QPEffect *obj, NSUInteger idx, BOOL *stop) {
        if (obj.eid == eid) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (void)deleteEffectById:(NSUInteger)eid type:(QPEffectType)type {
    switch (type) {
        case QPEffectTypeMV:
            [self.mvManager deleteEffectMVByID:eid];
            break;
            
        default:
            break;
    }
}


#pragma mark - mv

- (void)updateMVEffect {
    [self.mvManager refresh];
}

- (NSMutableArray *)getLocalMVEffects {
    return [self.mvManager localEffectMVs];
}

#pragma mark - music
- (void)needUpdateMusicData {
    _arrayMusic  = [self.musicManager createMusic];
}

#pragma mark - remote

- (void)downEffect:(QPEffect *)effect {
    [self.downManager downEffect:effect];
}

#pragma mark - down manager delegate

-(void)didFinishDownEffect:(QPEffect *)effect {
//    if (effect.type == QPEffectTypeMV) {
//        [_arrayMV addObject:effect];
//    }
}


#pragma mark - Getter Setter 

- (QPEffectMVManager *)mvManager {
    if (!_mvManager) {
        _mvManager = [[QPEffectMVManager alloc] init];
    }
    return _mvManager;
}

-(QPEffectMusicManager *)musicManager {
    if (!_musicManager) {
        _musicManager = [[QPEffectMusicManager alloc] init];
    }
    return _musicManager;
}

-(QPEffectFilterManager *)filterManager {
    if (!_filterManager) {
        _filterManager = [[QPEffectFilterManager alloc] init];
    }
    return _filterManager;
}

-(QPEffectDownManager *)downManager {
    if (!_downManager) {
        _downManager = [[QPEffectDownManager alloc] init];
        _downManager.delegate = self;
    }
    return _downManager;
}

@end
