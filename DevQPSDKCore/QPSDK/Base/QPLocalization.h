//
//  QPLocalizable.h
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 15/12/8.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QPLocalization : NSObject
@property (strong, nonatomic) NSURL *localizableFileUrl;
+ (instancetype)shared;
- (void)reset;
- (NSString *)localizedString:(NSString *)key;
@end
