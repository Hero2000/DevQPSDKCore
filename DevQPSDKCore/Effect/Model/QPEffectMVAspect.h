//
//  QPEffectMVAspect.h
//  DevQPSDKCore
//
//  Created by Worthy on 16/9/18.
//  Copyright © 2016年 LYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

static NSString *const QPEffectMVAspect1To1 = @"1";
static NSString *const QPEffectMVAspect4To3 = @"2";
static NSString *const QPEffectMVAspect9To16 = @"3";


@protocol QPEffectMVAspect <NSObject>

@end

@interface QPEffectMVAspect : JSONModel
@property (nonatomic, copy) NSString *aspect;
@property (nonatomic, copy) NSString *download;
@property (nonatomic, copy) NSString *md5;
@end
