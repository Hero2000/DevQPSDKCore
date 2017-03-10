//
//  QPUploadTaskManager.m
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 16/1/12.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "QPUploadTaskManager.h"
#import "QPUploadTaskCache.h"
#import "NSData+QPMD5.h"
#import <QPSDKCore/QPHttpClient.h>
#include <CommonCrypto/CommonDigest.h>

typedef void (^QPContentPartUploadBlock)(QPUploadTask *uploadTask, NSError *error);

@implementation QPUploadTaskManager

+ (instancetype)shared {
    static QPUploadTaskManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[QPUploadTaskManager alloc] init];
    });
    return manager;
}

#pragma mark - Public

- (QPUploadTask *)createUploadTaskWithVideoPath:(NSString *)videoPath
                                  thumbnailPath:(NSString *)thumbnailPath {
    return [self createUploadTaskWithVideoPath:videoPath thumbnailPath:thumbnailPath share:0 desc:nil tags:nil];
}

- (QPUploadTask *)createUploadTaskWithVideoPath:(NSString *)videoPath
                                  thumbnailPath:(NSString *)thumbnailPath
                                          share:(NSInteger)share
                                           desc:(NSString *)desc
                                           tags:(NSString *)tags {
    QPUploadTask *task = [[QPUploadTask alloc] init];
    task.videoPath = videoPath;
    task.thumbnailPath = thumbnailPath;
    task.taskId = gen_uuid();
    task.videoMD5 = [self fileMD5:videoPath];
    NSDictionary *videoAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil];
    NSInteger videoLength = [[videoAttributes objectForKey:NSFileSize] integerValue];
    task.videoLength = videoLength;
    NSDictionary *thumbnailAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:thumbnailPath error:nil];
    NSInteger thumbnailLength = [[thumbnailAttributes objectForKey:NSFileSize] integerValue];
    task.thumbnailLength = thumbnailLength;
    task.desc = desc;
    task.share = share;
    task.tags = tags;
    [[QPUploadTaskCache shared] saveUploadTask:task];
    return task;
}


- (void)startUploadTask:(QPUploadTask *)uploadTask
               progress:(void(^)(CGFloat progress))progress
                success:(void(^)(QPUploadTask *uploadTask, NSString *remoteId))success
                failure:(void(^)(NSError *error))failure {
    if (![QPAuth shared].accessToken) {
        failure([NSError errorWithDomain:@"qupai" code:101 userInfo:@{@"message":@"未取得AccessToken"}]);
        return;
    }
    if (![QPAuth shared].space) {
        failure([NSError errorWithDomain:@"qupai" code:101 userInfo:@{@"message":@"未指定space"}]);
        return;
    }
    
    if (uploadTask.uploadId.length > 0) {
        [self updateNextPart:uploadTask progress:progress success:^(NSString *remoteId) {
            success(uploadTask,remoteId);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }else {
        [self contentMetaUploadWithUploadTask:uploadTask completeHandler:^(QPUploadTask *uploadTask, NSError *error) {
            if (!error) {
                [self updateNextPart:uploadTask progress:progress success:^(NSString *remoteId) {
                    success(uploadTask,remoteId);
                } failure:^(NSError *error) {
                    failure(error);
                }];
            }else{
                failure(error);
            }

        }];
     }
}

- (void)removeUploadTask:(QPUploadTask *)uploadTask {
    [[QPUploadTaskCache shared] removeUploadTask:uploadTask];

}
- (NSArray *)getAllUploadTasks {
    return [[QPUploadTaskCache shared] getAllUploadTasks];
}

- (void)removeAllUploadTasks {
    [[QPUploadTaskCache shared] removeAllUploadTasks];
}

#pragma mark - part

- (void)updateNextPart:(QPUploadTask *)uploadTask progress:(void(^)(CGFloat progress))progress success:(void(^)(NSString *remoteId))success failure:(void(^)(NSError *error))failure {
    if (uploadTask.uploadFinished) {
        [[QPUploadTaskCache shared] removeUploadTask:uploadTask];
        progress(1.0);
        success(uploadTask.remoteId);
        return;
    }else {
        progress([uploadTask progress]);
    }
    [self contentPartUploadWithUploadTask:uploadTask completeHandler:^(QPUploadTask *uploadTask, NSError *error) {
        if (error) {
            failure(error);
            return;
        }else{
            [self updateNextPart:uploadTask progress:progress success:success failure:failure];
        }
    }];
}

#pragma mark - Content upload

- (void)contentMetaUploadWithUploadTask:(QPUploadTask *)uploadTask completeHandler:(QPContentPartUploadBlock)handler {
    NSString *packageName = [[NSBundle mainBundle] bundleIdentifier];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"size":@(uploadTask.videoLength),
                                                                                  @"packageName":packageName,
                                                                                  @"accessToken":[QPAuth shared].accessToken,
                                                                                  @"quid":[QPAuth shared].space,
                                                                                  @"md5":uploadTask.videoMD5,
                                                                                  @"share":@(uploadTask.share)}];
    if (uploadTask.tags && uploadTask.tags.length) {
        [params setObject:uploadTask.tags forKey:@"tags"];
    }
    if (uploadTask.desc && uploadTask.desc.length) {
        [params setObject:uploadTask.desc forKey:@"description"];
    }
    
    NSData *imageData = [NSData dataWithContentsOfFile:uploadTask.thumbnailPath];
    QPHttpClient *client = [QPHttpClient clientWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kQPUploadHostUrl, @"content/meta/upload"]] params:params];
    [client appendPartWithFileData:imageData name:@"thumbnail" fileName:[uploadTask.thumbnailPath lastPathComponent] mimeType:[NSString stringWithFormat:@"image/%@",[uploadTask.thumbnailPath pathExtension]]];
    [client postWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            handler(0,connectionError);
            return;
        }
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            handler(0,error);
            return;
        }
        NSInteger code = [[dict valueForKey:@"code"] integerValue];
        if (code == 200) {
            NSDictionary *data = [dict objectForKey:@"data"];
            NSString *uploadId = [data objectForKey:@"id"];
            NSString *range = [data objectForKey:@"range"];
            uploadTask.uploadId = uploadId;
            uploadTask.range = range;
            [[QPUploadTaskCache shared] saveUploadTask:uploadTask];
            handler(uploadTask,nil);
        }else {
            handler(uploadTask,[NSError errorWithDomain:@"qupai" code:code userInfo:dict]);
        }
    }];
}

- (void)contentPartUploadWithUploadTask:(QPUploadTask *)uploadTask completeHandler:(QPContentPartUploadBlock)handler {
    
    NSArray *array = [uploadTask.range componentsSeparatedByString:@"-"];
    NSInteger from = [array[0] intValue];
    NSInteger to = [array[1] intValue];

    
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:uploadTask.videoPath];
    [fileHandler seekToFileOffset:from];
    NSData *subData = [fileHandler readDataOfLength:to - from];
    if (!subData) {
        handler(uploadTask, [NSError errorWithDomain:@"data not exist" code:400 userInfo:nil]);
        return;
    }
    
    NSDictionary *params = @{ @"accessToken":[QPAuth shared].accessToken,
                              @"quid":[QPAuth shared].space,
                             @"id":uploadTask.uploadId,
                             @"range":uploadTask.range,
                             @"md5":[subData md5]
                             };
    QPHttpClient *client = [QPHttpClient clientWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kQPUploadHostUrl, @"content/part/upload"]] params:params];
    [client appendPartWithFileData:subData name:@"video" fileName:[uploadTask.videoPath lastPathComponent] mimeType:[NSString stringWithFormat:@"video/%@",[uploadTask.videoPath pathExtension]]];
    [client postWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            handler(0,connectionError);
            return;
        }
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            handler(0,error);
            return;
        }
        NSInteger code = [[dict valueForKey:@"code"] integerValue];
        if (code == 200) {                                          // 分片上传完成
            NSDictionary *data = [dict objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {    // 非最后一片
                NSString *range = [data objectForKey:@"range"];
                uploadTask.range = range;
            }else {                                             // 是最后一片
                uploadTask.remoteId = [dict objectForKey:@"data"];
                uploadTask.uploadFinished = YES;
            }
            [[QPUploadTaskCache shared] saveUploadTask:uploadTask];
            handler(uploadTask, nil);
        }else if (code == 101){                                     // 分片已经上传
            NSDictionary *data = [dict objectForKey:@"data"];
            if ([data isKindOfClass:[NSNull class]]) {
                handler(uploadTask, [NSError errorWithDomain:@"qupai" code:code userInfo:dict]);
                return;
            }
            NSString *range = [data objectForKey:@"range"];
            uploadTask.range = range;
            [[QPUploadTaskCache shared] saveUploadTask:uploadTask];
            handler(uploadTask, nil);
        }else {                                                 // 发生错误
            handler(uploadTask, [NSError errorWithDomain:@"qupai" code:code userInfo:dict]);
        }
    }];
}



#pragma mark - Tool

NSString * gen_uuid()
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}

- (NSString*)fileMD5:(NSString*)path
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength:1024 * 1024];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if( [fileData length] == 0 ) done = YES;
        
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}

@end
