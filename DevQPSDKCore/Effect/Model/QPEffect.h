//
//  QPEffect.h
//  QupaiSDK
//
//  Created by yly on 15/6/18.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

typedef NS_ENUM(NSInteger, QPEffectType) {
    QPEffectTypeUnKnow,
    QPEffectTypePaster,
    QPEffectTypeFont,
    QPEffectTypeMusic,
    QPEffectTypeFilter,
    QPEffectTypePureMusic,
    QPEffectTypeMV
};

typedef NS_ENUM (NSInteger, QPEffectItemDownStatus){
    QPEffectItemDownStatusNone = 0,
    QPEffectItemDownStatusDowning,
    QPEffectItemDownStatusFailed,
    QPEffectItemDownStatusFinish,
    QPEffectItemDownStatusLocal,
    QPEffectItemDownStatusUnZip,
    QPEffectItemDownStatusInstall
};


@interface QPEffect : JSONModel
//@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) QPEffectType type;
@property (nonatomic, assign) NSInteger eid;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString <Optional>*resourceUrl;
@property (nonatomic, copy) NSString <Optional>*iconUrl;
@property (nonatomic, copy) NSString <Optional>*thumbnailsUrl;

// local
@property (nonatomic, assign) QPEffectItemDownStatus downStatus;
@property (nonatomic, assign) CGFloat downProgress;
@property (nonatomic, copy) NSString *resourceLocalUrl;


- (BOOL)isMore;
- (BOOL)isEmpty;
+ (NSString *)storageDirectoryWithEffectType:(QPEffectType)type;
    
    
@end
