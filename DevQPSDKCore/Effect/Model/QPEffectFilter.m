//
//  QPEffectFilter.m
//  QupaiSDK
//
//  Created by yly on 15/6/18.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPEffectFilter.h"
//#import "QUMVTemplate.h"

@implementation QPEffectFilter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = QPEffectTypeFilter;
    }
    return self;
}

- (QUMVTemplate *)mvTemplate
{
//    if (_mvTemplate && _mvPath) {
//        NSString *dic = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//        NSString *path = [[[QPBundle mainBundle] bundlePath] stringByAppendingPathComponent:_mvPath];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
//            NSString *path = [[dic stringByAppendingPathComponent:@"resshop"] stringByAppendingPathComponent:_mvPath];
//            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
//                _mvTemplate = nil;//下载的mv还会存在，如果删除了，在草稿箱的mvTemplate还会有值，测清除
//                _mvPath = @"extra/mvraw";
//            }
//        }
//    }
//    if (!_mvTemplate && _mvPath) {
//        _mvTemplate = [QUMVTemplate createWithDirectory:[[[QPBundle mainBundle] bundlePath] stringByAppendingPathComponent:_mvPath]];
//        if (!_mvTemplate) {
//            NSString *dic = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//            NSString *path = [[dic stringByAppendingPathComponent:@"resshop"] stringByAppendingPathComponent:_mvPath];
//            _mvTemplate = [QUMVTemplate createWithDirectory:path];
//        }
//        if (!_mvTemplate) {
//            NSString *path = [[QPBundle mainBundle] pathForResource:@"extra/mvraw" ofType:@""];
//            _mvTemplate = [QUMVTemplate createWithDirectory:path];
//        }
//    }
    return _mvTemplate;
}

@end
