//
//  JSONModel.h
//  QupaiSDK
//
//  Created by yly on 15/6/26.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Ignore
@end

@protocol Optional
@end


@interface QPJSONModel : NSObject


- (instancetype)initWithString:(NSString*)string error:(NSError**)err;

/**
 *  创建JSONModel
 *
 *  @param dic   数据字典
 *  @return      JSONModel
 */
- (instancetype)initWithDictionary:(NSDictionary *)dic;

/**
 *  创建JSONModel
 *
 *  @param path   文件路径
 *  @return       JSONModel
 */
- (instancetype)initWithFile:(NSString *)path;


/**
 *  转换字典
 *
 *  @return      数据字典
 */
- (NSDictionary *)toDictionary;

/**
 *  文件写入数据
 *
 *  @param path 路径
 */
- (void)jsonToFile:(NSString *)path;

@end
