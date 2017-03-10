//
//  QPEffectMV.m
//  DevQPSDKCore
//
//  Created by Worthy on 16/8/29.
//  Copyright © 2016年 LYZ. All rights reserved.
//

#import "QPEffectMV.h"

@implementation QPEffectMV
    

- (NSString *)resourceLocalRatioPathWithRatio:(QPEffectMVRatio)ratio {
    NSString *rootPath = self.resourceLocalUrl;
    NSString *folderName = nil;
    NSArray *subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:nil];
    if (subPaths.count) {
        BOOL hasFolder = NO;
        for (NSString *subPath in subPaths) {
            if ([subPath hasPrefix:@"folder"]) {
                hasFolder = YES;
                folderName = subPath;
                break;
            }
        }
        if (!hasFolder) {
            return rootPath;
        }
    }
    
    NSString *folder = folderName;
    switch (ratio) {
        case QPEffectMVRatio1To1:
            folder = @"folder1.1";
            break;
        case QPEffectMVRatio16To9:
            folder = @"folder16.9";
            break;
        case QPEffectMVRatio9To16:
            folder = @"folder9.16";
            break;
        case QPEffectMVRatio4To3:
            folder = @"folder4.3";
            break;
        case QPEffectMVRatio3To4:
            folder = @"folder1.1";
            break;
        default:
            break;
    }
    if (folder) {
        return [rootPath stringByAppendingPathComponent:folder];
    }
    return rootPath;
    
}
    
- (NSString *)resourceLocalIconPath {
    NSString *rootPath = self.resourceLocalUrl;
    NSString *folderName = nil;
    NSArray *subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:nil];
    if (subPaths.count) {
        BOOL hasFolder = NO;
        for (NSString *subPath in subPaths) {
            if ([subPath hasPrefix:@"folder"]) {
                hasFolder = YES;
                folderName = subPath;
                break;
            }
        }
        if (!hasFolder) {
            return [rootPath stringByAppendingPathComponent:@"icon.png"];
        }
        return [[rootPath stringByAppendingPathComponent:folderName] stringByAppendingPathComponent:@"icon.png"];
    }
    return nil;
}
    
@end
