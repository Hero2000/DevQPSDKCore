//
//  QPVideo.m
//  QupaiSDK
//
//  Created by yly on 15/6/17.
//  Copyright (c) 2015年 lyle. All rights reserved.
//
#import "QupaiSDK.h"
#import "QPVideo.h"
#import "QPVideoPoint.h"


@interface QPVideo()
@property (nonatomic, assign, readwrite) CGFloat duration;
@end

@implementation QPVideo
{
    NSMutableArray *_arrayPoint;
}

- (id)init
{
    if ((self = [super init])) {
        _packName = [QPVideo uuid];
        _arrayPoint = [NSMutableArray arrayWithCapacity:4];
        _bitRate = 2 * 1000 * 1000;
        _duration = 0;
        _maxDuration = 8.0;
        _minDuration = 2.0;
        _mixVolume = 1.0;
        _configFileName = @"config.json";
        return self;
    }
    return nil;
}

- (instancetype)initWithPack:(NSString *)path
{
    return [self initWithFile:[path stringByAppendingPathComponent:@"config.json"]];
}

- (void)setupMaxDuration:(CGFloat)maxDuration bitRate:(NSUInteger)bitRate
{
//    _maxDuration = MIN(MAX(maxDuration, 8.0), 30.0);
//    _bitRate = MIN(MAX(bitRate, 0.5 * 1000 * 1000), 100 * 1000 * 1000);
    _maxDuration = maxDuration;
    _bitRate     = bitRate;
}

- (void)setupMinDuration:(CGFloat)minDuration maxDuration:(CGFloat)maxDuration bitRate:(NSUInteger)bitRate
{
    _minDuration = minDuration;
    _maxDuration = maxDuration;
    _bitRate     = bitRate;
}


- (CGSize)size
{
    // TODO 需要修改
    if (_arrayPoint.count) {
        QPVideoPoint *point =[_arrayPoint objectAtIndex:0];
        AVURLAsset *asset = [AVURLAsset assetWithURL:[self fullURLForFileName:point.fileName]];
        AVAssetTrack *assetTrackVideo;
        if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
            assetTrackVideo = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        }
        CGSize videoSize = assetTrackVideo.naturalSize;
        CGAffineTransform trackTrans = assetTrackVideo.preferredTransform;
        if ((trackTrans.b == 1 && trackTrans.c == -1)||(trackTrans.b == -1 && trackTrans.c == 1)) {
            videoSize = CGSizeMake(videoSize.height, videoSize.width);
        }
        if (videoSize.width > 0 && videoSize.height > 0) {
            return videoSize;
        }
    }

    return [QupaiSDK shared].videoSize;
}


- (void)letVideoDurationLessMaxDuration
{
    if (_duration >= _maxDuration) {
        self.lastPoint.endTime = self.maxDuration - 0.01;
        self.duration = self.maxDuration - 0.01;
    }
}

+ (NSURL *)movieFirstFrame:(NSURL *)videoURL toPath:(NSString *)toPath quality:(CGFloat)quality
{
    NSError *error = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    if([manager fileExistsAtPath:videoURL.path]){
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
        generator.appliesPreferredTrackTransform = YES;
        CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 30) actualTime:NULL error:&error];
        UIImage *image = [UIImage imageWithCGImage:img];
        CGImageRelease(img);
        NSData *data = UIImageJPEGRepresentation(image, quality);
        [data writeToFile:toPath atomically:YES];
        return [NSURL fileURLWithPath:toPath];
    }
    return nil;
}

#pragma mark - Point
- (NSMutableArray *)points {
    return _arrayPoint;
}

- (NSUInteger)pointCount
{
    return _arrayPoint.count;
}

- (QPVideoPoint *)pointAtIndex:(NSUInteger)index
{
    if (index > [self pointCount] - 1) {
        return nil;
    }
    return _arrayPoint[index];
}

- (QPVideoPoint *)lastPoint
{
    return _arrayPoint.lastObject;
}

- (BOOL)removeAllPoint
{
    for (QPVideoPoint *vp in _arrayPoint) {
        [[NSFileManager defaultManager] removeItemAtPath:[self fullPathForFileName:vp.fileName] error:nil];
    }
    [_arrayPoint removeAllObjects];
    _mixVolume = 1.0;
    _musicID = 0;
    _mvID = 0;
    _filterID = 0;
    _lastEffectName = nil;
    _lastSelected = NO;
    self.duration = 0;
    return YES;
}

- (BOOL)removeLastPoint
{
    if ([self pointCount] == 1) {
        return [self removeAllPoint];//删除最后一段，执行清除操作
    }
    [[NSFileManager defaultManager] removeItemAtPath:[self fullPathForFileName:self.lastPoint.fileName] error:nil];
    [_arrayPoint removeLastObject];
    self.duration = self.lastPoint.endTime;
    return YES;
}

//- (BOOL)removeRecordFile
//{
//    [[NSFileManager defaultManager] removeItemAtPath:[self fullPathForFileName:self.recordFileName] error:nil];
//    _recordFileName = nil;
//    return YES;
//}

- (void)addNewVideoPoint:(QPVideoPoint *)vp
{
    _lastSelected = NO;
    [_arrayPoint addObject:vp];
}

- (QPVideoPoint *)addVideoPointByPath:(NSString *)path
{
    NSError *error = nil;
    CGFloat videoDuration = 0;
    NSString *fileName = [self newUniqueFileNameWithExt:@"mp4"];
    if (path) {
        NSString *toPath = [self fullPathForFileName:fileName];
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:&error];
        videoDuration = CMTimeGetSeconds(((AVURLAsset *)[AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]]).duration);
    }
    if (error) {
        return nil;
    }
    
    QPVideoPoint *vp = [[QPVideoPoint alloc] init];
    vp.startTime = _duration;
    vp.endTime = _duration;
    vp.fileName = fileName;
    vp.rotate = 0;
    
    [self addNewVideoPoint:vp];
    [self updateLastVideoDuration:videoDuration];
    return vp;
}

- (QPVideoPoint *)addEmptyVideoPoint
{
    return [self addVideoPointByPath:nil];
}

- (void)updateLastVideoDuration:(CGFloat)duration
{
    self.duration = self.lastPoint.endTime = self.lastPoint.startTime + duration;
}

- (NSMutableArray *)AllPointsRotate {
    
    NSMutableArray *rotateArray = [NSMutableArray array];
    for (int i = 0; i < [self pointCount]; i++) {
        [rotateArray addObject:[NSNumber numberWithInteger:[_arrayPoint[i] rotate]]];
    }
    return rotateArray;
}

- (UIImage *)lastFrameOfVideo {
    if (_arrayPoint.count) {
        QPVideoPoint *lastPoint = _arrayPoint.lastObject;
        AVURLAsset *asset = [AVURLAsset assetWithURL:[self fullURLForFileName:lastPoint.fileName]];
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        CGImageRef imageRef = [generator copyCGImageAtTime:asset.duration actualTime:nil error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return image;
    }
    return nil;
}

#pragma mark - Check

- (BOOL)isEmpty
{
    return self.pointCount == 0;
}

- (BOOL)synchronizeToDisk
{
    [self jsonToFile:[self fullPathForFileName:self.configFileName]];
    return YES;
}
#pragma mark - finish

- (void)combineVideoWithCompletionBlock:(void(^)(NSError *error))block
{

//    if ([self pointCount] == 1 && self.lastPoint.rotate % 4 == 0) {
//        if ([QupaiSDK shared].enableVideoEffect) {
//            NSString *fileName = [self newUniqueFileNameWithExt:@"mp4"];
//            NSString *toPath = [self fullPathForFileName:fileName];
//            NSString *fromPath = [self fullPathForFileName:self.lastPoint.fileName];
//            [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error:nil];
//            _recordFileName = fileName;
//            block(nil);
//            return;
//        }
//    }
    BOOL changeAngle = NO;
    QPVideoCombine *stitcher = [[QPVideoCombine alloc] initWithOutputSize:self.size];
    for (int i = 0; i < self.pointCount; ++i) {
        QPVideoPoint *vp = [self pointAtIndex:i];
        NSURL *url = [self fullURLForFileName:vp.fileName];
        AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
        [stitcher addAsset:asset rotate:vp.rotate withError:nil];
        if (vp.rotate != 0 && vp.rotate != 4 && !changeAngle) {
            changeAngle = YES;
        }
    }
    
    // 反序排列
    /*
    for (int i = self.pointCount - 1; i >= 0; --i) {
        QPVideoPoint *vp = [self pointAtIndex:i];
        NSURL *url = [self fullURLForFileName:vp.fileName];
        AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
        [stitcher addAsset:asset rotate:vp.rotate withError:nil];
        if (vp.rotate != 0 && vp.rotate != 4 && !changeAngle) {
            changeAngle = YES;
        }
    }
    */
    NSURL *url = [NSURL fileURLWithPath:[self newUniquePathWithExt:@"mp4"]];
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    NSString *preset = changeAngle ? AVAssetExportPresetHighestQuality : AVAssetExportPresetPassthrough;
    if ([QupaiSDK shared].enableVideoEffect) {
        [stitcher exportTo:url withPreset:preset withCompletionHandler:^(NSError *error) {
            _recordFileName = error ? nil : [url.path lastPathComponent];
            if (block) {
                block(error);
            }
        }];
    }else{
        preset = AVAssetExportPresetHighestQuality;
        stitcher.shouldOptimizeForNetworkUse = YES;
        [stitcher exportTo:url withPreset:preset waterMark:[QupaiSDK shared].watermarkImage completionHandler:^(NSError *error) {
            if (!error) {
                // 合成完毕后转码
                AVAsset *asset = [AVAsset assetWithURL:url];
                NSURL *outUrl = [NSURL fileURLWithPath:[self newUniquePathWithExt:@"mp4"]];
                QPReaderToWriter *readerToWriter = [[QPReaderToWriter alloc] init];
                [readerToWriter combineFromAsset:asset toURL:outUrl withBitRate:self.bitRate completionHandler:^(NSError *error) {
                    
                    _recordFileName = error ? nil : [outUrl.path lastPathComponent];
                    if (block) {
                        block(error);
                    }
                }];
            }else{
                block(error);
            }
            
        }];
    }
}

- (NSString *)fullPathForFileName:(NSString *)fileName
{
    NSString *rootPath = [QPVideo videoFullPathForVideoPackName:_packName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [rootPath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (NSURL *)fullURLForFileName:(NSString *)fileName
{
    return [NSURL fileURLWithPath:[self fullPathForFileName:fileName]];
}

+ (NSString *)videoFullPathForVideoPackName:(NSString *)dir
{
    static NSString *_basePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _basePath = [documentPath stringByAppendingPathComponent:@"com.duanqu.qupaisdk"];
    });
    NSString *rootPath = [_basePath stringByAppendingPathComponent:dir];
    return rootPath;
}

- (NSMutableArray *)fullPathsForFilePathArray {
    
    NSMutableArray *fileNameArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self pointCount]; i++) {
        [fileNameArray addObject:[self fullPathForFileName:[_arrayPoint[i] valueForKey:@"fileName"]]];
    }
    return fileNameArray;
}


#pragma mark - Dir
+ (NSString*)uuid{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

- (NSString *)newUniquePathWithExt:(NSString *)ext
{
    NSString *path = [self fullPathForFileName:[self newUniqueFileNameWithExt:ext]];
    return path;
}

- (NSString *)newUniqueFileNameWithExt:(NSString *)ext
{
    NSString *path = [[QPVideo uuid] stringByAppendingPathExtension:ext];
    return path;
}

#pragma mark - JSON

- (instancetype)customInit:(NSDictionary *)dic
{
    _arrayPoint = [NSMutableArray array];
    for (NSDictionary *d in dic[@"arrayPoint"]) {
        [_arrayPoint addObject:[[QPVideoPoint alloc] initWithDictionary:d]];
    }
    return self;
}
- (NSDictionary *)customToDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *newDict = [dict mutableCopy];
    NSMutableArray *array = [NSMutableArray array];
    for (QPVideoPoint *vp in _arrayPoint) {
        [array addObject:[vp toDictionary]];
    }
    newDict[@"arrayPoint"] = array;
    return newDict;
}
@end
