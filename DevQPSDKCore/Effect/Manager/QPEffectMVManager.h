//
//  QPEffectMVManager.h
//  DevQPSDKCore
//
//  Created by Worthy on 16/8/29.
//  Copyright © 2016年 LYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QPEffectMV.h"

@interface QPEffectMVManager : NSObject
@property (nonatomic, strong) NSMutableArray *mvs;

- (NSMutableArray *)loadEffectMVs;

- (NSMutableArray *)bundleEffectMVs;
- (NSMutableArray *)localEffectMVs;

- (void)deleteEffectMVByID:(NSUInteger)eid;


- (void)refresh;

@end
