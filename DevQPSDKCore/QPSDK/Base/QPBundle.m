//
//  QPBundle.m
//  QupaiSDK
//
//  Created by yly on 15/6/17.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPBundle.h"

@implementation QPBundle

+ (NSBundle *)qp_bundle
{
    
#ifdef kQPSDKLite
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"QuPaiSDKLiteRes" withExtension:@"bundle"]];
#else
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"QPSDK" withExtension:@"bundle"]];
#endif
    

    return bundle;
}

+ (NSBundle *)mainBundle
{
    return [QPBundle qp_bundle];
}

@end
