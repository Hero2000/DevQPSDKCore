//
//  LibrarayTool.h
//  duanqu2
//
//  Created by lyle on 14-2-28.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface QPPickerLibraray : NSObject

@property (nonatomic, strong) ALAssetsLibrary *library;
@property (nonatomic, assign) ALAssetsGroupType groupType;
@property (nonatomic, strong) NSString *groupName;

@property (nonatomic, strong) void(^itemsCompleteBlock)(NSArray *items, NSInteger count);
@property (nonatomic, strong) void(^failedBlock)(NSError *error);

- (void)startLibrary;
@end
