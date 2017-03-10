//
//  VideoPoint.h
//  QupaiSDK
//
//  Created by yly on 15/6/16.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QPVideoPoint : QPJSONModel

@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) NSInteger rotate;//选择角度1：90，2：180
@end
