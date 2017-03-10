//
//  QPImage.m
//  QupaiSDK
//
//  Created by yly on 15/6/17.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPImage.h"

@implementation QPImage

+ (UIImage *)imageNamed:(NSString *)name
{
    UIImage *image = [UIImage imageWithContentsOfFile:name];
    if (image) {
        return image;
    }
#ifdef kQPSDKLite
    NSString *path = [NSString stringWithFormat:@"%@/%@",@"QuPaiSDKLiteRes.bundle",name];
    
#else
    NSString *path = [NSString stringWithFormat:@"%@/%@",@"QPSDK.bundle",name];
#endif
    
    return [UIImage imageNamed:path];
}

@end
