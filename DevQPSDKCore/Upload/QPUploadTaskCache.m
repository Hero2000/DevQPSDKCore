//
//  QPUploadTaskCache.m
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 16/1/12.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "QPUploadTaskCache.h"

@implementation QPUploadTaskCache

+ (instancetype)shared {
    static QPUploadTaskCache *uploadCache = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        uploadCache = [[QPUploadTaskCache alloc] init];
    });
    return uploadCache;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self createDictionary];
    }
    return self;
}

- (void)createDictionary {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *configPath = [documentPath stringByAppendingPathComponent:@"com.duanqu.qupaisdk.config"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:configPath]) {
        [fileMgr createDirectoryAtPath:configPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)configPath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *configPath = [documentPath stringByAppendingPathComponent:@"com.duanqu.qupaisdk.config"];
    return configPath;
}

#pragma mark - public methods

- (void)saveUploadTask:(QPUploadTask *)uploadTask {
    [self createDictionary];
    NSString *taskPath = [[[self configPath] stringByAppendingPathComponent:uploadTask.taskId] stringByAppendingPathExtension:@"config"];
    [uploadTask jsonToFile:taskPath];
}

- (NSArray *)getAllUploadTasks {
    NSMutableArray *tasks = [NSMutableArray array];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *configPath = [self configPath];
    NSError *error = nil;
    NSArray *names = [fileMgr contentsOfDirectoryAtPath:configPath error:&error];
    if (!error) {
        NSArray *files = [names pathsMatchingExtensions:@[@"config"]];
        for (NSString *file in files) {
            QPUploadTask *task = [[QPUploadTask alloc] initWithFile:[configPath stringByAppendingPathComponent:file]];
            [tasks addObject:task];
        }
    }
    return tasks;
}

- (void)removeAllUploadTasks {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *configPath = [self configPath];
    [fileMgr removeItemAtPath:configPath error:nil];
}

- (void)removeUploadTask:(QPUploadTask *)uploadTask {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *configPath = [self configPath];
    NSString *taskPath = [[configPath stringByAppendingPathComponent:uploadTask.taskId] stringByAppendingPathExtension:@"config"];
    [fileMgr removeItemAtPath:taskPath error:nil];
}

@end
