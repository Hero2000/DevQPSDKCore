//
//  QPEventManager.m
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 15/12/23.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import "QPEventManager.h"
#import <sys/utsname.h>
#import "NSData+QPMD5.h"


//static NSString * const Secret = @"3420242";

static NSString * const kQupaiSDKEventKey = @"__qupai_sdk_event_key__";

@interface QPEventManager ()
@property (nonatomic, strong) NSMutableArray *eventArray;
@end

@implementation QPEventManager

+ (instancetype)shared {
    static QPEventManager *eventManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        eventManager = [[QPEventManager alloc] init];
    });
    return eventManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.eventArray = [NSMutableArray arrayWithArray:[self getLocalEvents]];
    }
    return self;
}

#pragma mark - Persistent

- (NSArray *)getLocalEvents {
    NSArray *array = [[NSUserDefaults standardUserDefaults] valueForKey:kQupaiSDKEventKey];
    return array;
}

- (void)saveEvents {
    [[NSUserDefaults standardUserDefaults] setObject:self.eventArray forKey:kQupaiSDKEventKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.eventArray.count >= 10) {
        [self uploadEvents];
    }
}

#pragma mark - Public Methods

- (void)event:(NSString *)event {
#ifndef kQPEnableUploadInfo
    return;
#endif
    double time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSDictionary *dict = @{
                           @"name":event,
                           @"time":[NSNumber numberWithLongLong:time]
                           };
    [self.eventArray addObject:dict];
    [self saveEvents];
}

- (void)event:(NSString *)event withParams:(NSDictionary *)params {
#ifndef kQPEnableUploadInfo
    return;
#endif
    double time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSDictionary *dict = @{
                           @"name":event,
                           @"params":params,
                           @"time":[NSNumber numberWithLongLong:time]
                           };
    [self.eventArray addObject:dict];
    [self saveEvents];
}

- (void)uploadEvents {

}

- (void)uploadAppInfo {

    
}
@end
