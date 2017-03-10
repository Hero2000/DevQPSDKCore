//
//  QPVideo.h
//  QupaiSDK
//
//  Created by yly on 15/6/17.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QPVideoPoint.h"
//@class QPVideoPoint;

@interface QPVideo : QPJSONModel

@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, assign, readonly) NSUInteger bitRate;
@property (nonatomic, assign, readonly) CGFloat duration;
@property (nonatomic, assign, readonly) CGFloat minDuration;
@property (nonatomic, assign, readonly) CGFloat maxDuration;
@property (nonatomic, strong, readonly) NSString *recordFileName;
@property (nonatomic, strong, readonly) NSString *configFileName;
@property (nonatomic, strong, readonly) NSString *packName; //唯一的id，也是视频的目录

@property (nonatomic, assign) CGFloat mixVolume;
@property (nonatomic, assign) NSInteger filterID;
@property (nonatomic, assign) NSInteger mvID;
@property (nonatomic, assign) BOOL preferFilterOrMV; // YES:filter NO:MV
@property (nonatomic, assign) NSInteger musicID;
@property (nonatomic, strong) NSString *lastEffectName;
@property (nonatomic, assign) BOOL lastSelected;

+ (NSURL *)movieFirstFrame:(NSURL *)videoURL toPath:(NSString *)toPath quality:(CGFloat)quality;
+ (NSString *)videoFullPathForVideoPackName:(NSString *)dir;

- (instancetype)initWithPack:(NSString *)path;

- (void)setupMaxDuration:(CGFloat)maxDuration bitRate:(NSUInteger)bitRate;
- (void)setupMinDuration:(CGFloat)minDuration maxDuration:(CGFloat)maxDuration bitRate:(NSUInteger)bitRate;

- (NSMutableArray *)points;
- (NSUInteger)pointCount;
- (QPVideoPoint *)pointAtIndex:(NSUInteger)index;
- (QPVideoPoint *)lastPoint;
- (UIImage *)lastFrameOfVideo;

- (NSMutableArray *)AllPointsRotate;

- (BOOL)removeAllPoint;
- (BOOL)removeLastPoint;
//- (BOOL)removeRecordFile;

- (NSString *)newUniquePathWithExt:(NSString *)ext;
- (NSString *)fullPathForFileName:(NSString *)fileName;
- (NSURL *)fullURLForFileName:(NSString *)fileName;

- (NSMutableArray *)fullPathsForFilePathArray;

- (QPVideoPoint *)addEmptyVideoPoint;
- (QPVideoPoint *)addVideoPointByPath:(NSString *)path;

- (BOOL)isEmpty;
- (BOOL)synchronizeToDisk;

- (void)updateLastVideoDuration:(CGFloat)duration;

- (void)letVideoDurationLessMaxDuration;/*效果界面返回，不自动下一步，让视频时长短一点*/

- (void)combineVideoWithCompletionBlock:(void(^)(NSError *error))block;
@end
