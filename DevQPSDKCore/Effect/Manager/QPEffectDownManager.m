//
//  QPEffectDownManager.m
//  DevQPSDKCore
//
//  Created by Worthy on 16/9/7.
//  Copyright © 2016年 LYZ. All rights reserved.
//

#import "QPEffectDownManager.h"
#import "AFNetworking.h"
#import "QPSSZipArchive.h"
#import "QPEffectMV.h"

typedef NS_ENUM(NSInteger,QPDownPathType){
    QPDownPathTypeDown,
    QPDownPathTypeUnzip,
    QPDownPathTypePath,
};

@implementation QPEffectDownManager

// step 1
- (void)downEffect:(QPEffect *)effect {
    if (effect.downStatus == QPEffectItemDownStatusDowning) return;
    effect.downStatus = QPEffectItemDownStatusDowning;
    NSString *path = [self directoryWithType:QPDownPathTypeDown effect:effect];
//    [self createDirectoryIfNeeded:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self downloadUrlForEffect:effect]]];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:^(NSProgress *downloadProgress){
                                                                         effect.downProgress = downloadProgress.fractionCompleted;
                                                                     }
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                        return [NSURL fileURLWithPath:path];
                                                                  }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                if (error) {
                                                                            effect.downProgress = 0.0;
                                                                            effect.downStatus = QPEffectItemDownStatusFailed;
                                                                }else {
                                                                            [self unzipEffect:effect];
                                                                }
                                                            }];
    [downloadTask resume];
}

// step 2
- (void)unzipEffect:(QPEffect *)effect {
    effect.downStatus = QPEffectItemDownStatusUnZip;
    NSString *zipPath = [self directoryWithType:QPDownPathTypeDown effect:effect];
    NSString *unZipPath = [self directoryWithType:QPDownPathTypeUnzip effect:effect];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [QPSSZipArchive unZipEffectItemAtPath:zipPath toDestination:unZipPath overwrite:YES password:nil error:nil block:^(bool finish,NSString *path, NSString *destination){
            if (finish) {
                [self saveEffect:effect unzippedPath:destination];
            }
        }];
    });

}

// step 3
- (void)saveEffect:(QPEffect *)effect unzippedPath:(NSString *)unzippedPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *unZipPath = [self directoryWithType:QPDownPathTypeUnzip effect:effect];
    NSString *effectPath = [self directoryWithType:QPDownPathTypePath effect:effect];
    if ([fm fileExistsAtPath:effectPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:effectPath error:nil];
    }
    
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:unZipPath];
    for (NSString *file in enumerator) {
        NSString *path = [unZipPath stringByAppendingPathComponent:file];
        NSDictionary *attribute = [fm attributesOfItemAtPath:path error:nil];
        NSString * fileType = attribute[NSFileType];
        
        if ([fileType isEqualToString:NSFileTypeDirectory]) {
            NSError *error = nil;
            if ([fm moveItemAtPath:path toPath:effectPath error:&error]) {
                [[NSFileManager defaultManager] removeItemAtPath:[self directoryWithType:QPDownPathTypeUnzip effect:effect] error:nil];
            }else{
                effect.downStatus = QPEffectItemDownStatusFailed;
                if ([fm fileExistsAtPath:unZipPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:unZipPath error:nil];
                }
            }
            break;
        }
    }
    effect.downStatus = QPEffectItemDownStatusFinish;
    if (_delegate) {
        [_delegate didFinishDownEffect:effect];
    }
}
    
    
    
#pragma mark - mv effect

-(NSString *)mvResourceUrl:(QPEffectMV *)effectMV {
    QPVideoRatio videoRatio = [[QupaiSDK shared] videoRatio];
    NSString *mvAspect = QPEffectMVAspect1To1;
    switch (videoRatio) {
        case QPVideoRatio16To9:
        case QPVideoRatio9To16:
        mvAspect = QPEffectMVAspect9To16;
        break;
        case QPVideoRatio4To3:
        case QPVideoRatio3To4:
        mvAspect = QPEffectMVAspect4To3;
        break;
        default:
        mvAspect = QPEffectMVAspect1To1;
        break;
    }
    for (QPEffectMVAspect *aspect in effectMV.aspectList) {
        if([aspect.aspect isEqualToString:mvAspect]){
            return aspect.download;
        }
    }
    return nil;
}


#pragma mark - tool
    
- (NSString *)downloadUrlForEffect:(QPEffect *)effect {
    if ([effect isKindOfClass:[QPEffectMV class]]) {
        return [self mvResourceUrl:(QPEffectMV *)effect];
    }
    return effect.resourceUrl;
}

- (NSString *)directoryWithType:(QPDownPathType)pathType effect:(QPEffect *)effect {
    NSString *fileName = [[NSURL URLWithString:[self downloadUrlForEffect:effect]] lastPathComponent];
    
    NSString *pathEffectType = [QPEffect storageDirectoryWithEffectType:effect.type];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir = paths.count > 0 ? paths[0] : nil;
    NSString *effectPath = [NSString stringWithFormat:@"%@/%zd-%@",pathEffectType,effect.eid,effect.name];
    if (pathType == QPDownPathTypeDown) {
        NSString * path =[NSString stringWithFormat:@"%@/temp%zd",pathEffectType,effect.eid];
        dir = [dir stringByAppendingPathComponent:path];
        BOOL isDir = YES;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        effectPath = [dir stringByAppendingPathComponent:fileName];
        return effectPath;
    }
    if (pathType == QPDownPathTypeUnzip) {
        effectPath =[NSString stringWithFormat:@"%@/temp%zd",pathEffectType,effect.eid];// /temp
    }
    dir = [dir stringByAppendingPathComponent:effectPath];
    if (pathType == QPDownPathTypePath) {
        return dir;
    }
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

@end
