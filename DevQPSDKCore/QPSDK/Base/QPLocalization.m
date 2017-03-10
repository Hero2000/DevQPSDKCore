//
//  QPLocalizable.m
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 15/12/8.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import "QPLocalization.h"


@interface QPLocalization ()
@property (strong, nonatomic) NSDictionary *dict;
@end

@implementation QPLocalization

+ (instancetype)shared {
    static QPLocalization *localization = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        localization = [[QPLocalization alloc] init];
        NSURL *fileUrl = [[QPBundle mainBundle] URLForResource:@"QPLocalizable" withExtension:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:fileUrl];
        localization.dict = dict;
    });
      return localization;
    return nil;
}

#pragma mark - Setter

-(void)setLocalizableFileUrl:(NSURL *)localizableFileUrl{
    _localizableFileUrl = localizableFileUrl;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:localizableFileUrl];
    self.dict = dict;
}

#pragma mark - Public Methods

- (NSString *)localizedString:(NSString *)key {
    NSString *value = [self.dict valueForKey:key];
    return value;
}

- (void)reset {
    NSURL *fileUrl = [[QPBundle mainBundle] URLForResource:@"QPLocalizable" withExtension:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:fileUrl];
    self.dict = dict;
}

@end
