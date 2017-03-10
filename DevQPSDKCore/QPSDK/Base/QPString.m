//
//  QPString.m
//  QupaiSDK
//
//  Created by yly on 15/6/18.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPString.h"

@implementation QPString

+ (CGSize)sizeWithFontSize:(CGFloat)size text:(NSString *)text
{
    UIFont *font = [UIFont systemFontOfSize:size];
    if (7.0 <= [[[UIDevice currentDevice] systemVersion] floatValue]) {
        return [text sizeWithAttributes:@{NSFontAttributeName:font}];
    }
    return [text sizeWithFont:font];
}


@end
