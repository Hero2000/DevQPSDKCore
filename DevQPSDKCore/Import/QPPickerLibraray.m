//
//  LibrarayTool.m
//  duanqu2
//
//  Created by lyle on 14-2-28.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import "QPPickerLibraray.h"
#import "QPLibrarayItem.h"
#import <Photos/Photos.h>

@implementation QPPickerLibraray
{
    ALAssetsGroup *_assetGroup;
}

- (id)init
{
    if (!(self = [super init])){
		return nil;
    }
    return self;
}

- (void)startLibrary
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self _startLibrary];
    });
}

- (ALAssetsLibrary *)_startLibrary
{
    if (_library == nil){
        _library = [[ALAssetsLibrary alloc] init];
    }
    [_library enumerateGroupsWithTypes:_groupType usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group && (_groupName ? [[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:_groupName] : YES)) {
            _assetGroup = group;
            *stop = YES;
        }
        if (group == nil) {
            [self createLibraryItems];
        }
    } failureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_failedBlock) {
                _failedBlock(error);
            }
        });
    }];
    return _library;
}

- (void)createLibraryItems
{
    NSMutableArray *a = [NSMutableArray array];
    [_assetGroup setAssetsFilter:[ALAssetsFilter allVideos]];
    [_assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result == nil) {
            return;
        }
        id rt = [result valueForProperty:ALAssetPropertyDuration];
        if (rt != ALErrorInvalidProperty) {
            int dur = [rt intValue];
            if ([QupaiSDK shared].minDuration <= dur && dur <= 10*60) {
                [a addObject:[QPLibrarayItem createFromAsset:result]];
            }
        }
    }];
    NSArray *sortItems = [a sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        QPLibrarayItem *m = obj1;
        QPLibrarayItem *n = obj2;
        return n.createtime > m.createtime;
    }];
    [self checkPhotoNewFeature:sortItems];
    if (_itemsCompleteBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
        _itemsCompleteBlock(sortItems, sortItems.count);
        });
    }
}

- (void)checkPhotoNewFeature:(NSArray *)items
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        return;
    }
    NSMutableArray *assetURLS = [NSMutableArray arrayWithCapacity:items.count];
    for (QPLibrarayItem *item in items) {
        [assetURLS addObject:item.url];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[
                                     [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                     ];
    PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:assetURLS options:fetchOptions];
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        if (asset.mediaSubtypes == PHAssetMediaSubtypeVideoHighFrameRate) {
            QPLibrarayItem *item = items[idx];
            item.type = QPLibrarayItemTypeHighFrameRate;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:
             ^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                 item.photoAsset = asset;
                 dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }else if(asset.mediaSubtypes == PHAssetMediaSubtypeVideoTimelapse){
            QPLibrarayItem *item = items[idx];
            item.type = QPLibrarayItemTypeTimelapse;
        }
    }];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self createLibraryItems];
}

- (void)dealloc
{
    NSLog(@"Library tool dealloc !");
}
@end
