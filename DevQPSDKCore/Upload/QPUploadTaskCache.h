//
//  QPUploadTaskCache.h
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 16/1/12.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QPUploadTask.h"

@interface QPUploadTaskCache : NSObject
+ (instancetype)shared;
- (void)saveUploadTask:(QPUploadTask *)uploadTask;
- (NSArray *)getAllUploadTasks;
- (void)removeAllUploadTasks;
- (void)removeUploadTask:(QPUploadTask *)uploadTask;
@end
