//
//  QPEffectDownManager.h
//  DevQPSDKCore
//
//  Created by Worthy on 16/9/7.
//  Copyright © 2016年 LYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QPEffect.h"

@protocol QPEffectDownManagerDelegate <NSObject>

- (void)didFinishDownEffect:(QPEffect *)effect;

@end
@interface QPEffectDownManager : NSObject

@property (nonatomic, weak) id<QPEffectDownManagerDelegate> delegate;

- (void)downEffect:(QPEffect *)effect;
@end

