//
//  QupaiSDK.m
//  QupaiSDK
//
//  Created by lyle on 13-12-19.
//  Copyright (c) 2013年 lyle. All rights reserved.
//

#import "QupaiSDK.h"
#import "QupaiSDK-Private.h"
#import "QPSave.h"
#import "QPEventManager.h"
#import "QPRecordViewController.h"
//#import "QPEffectViewController.h"

static QupaiSDK *_qupaiSDK = nil;

@implementation QupaiSDK

+ (instancetype)shared
{
    static QupaiSDK *_qupaiSDK = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qupaiSDK = [[QupaiSDK alloc] init];
    });
    return _qupaiSDK;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxDuration = 28.0;
        _minDuration = 2.0;
        _bitRate = 1024 * 1024 * 2;
        _thumbnailCompressionQuality = 0.8;
        _videoSize = CGSizeMake(640, 640);
        _watermarkImage = nil;
        _watermarkPosition = QupaiSDKWatermarkPositionTopRight;
        _enableBeauty = YES;
        _enableMoreMusic = YES;
        _enableImport = YES;
        _enableVideoEffect = YES;
        _enableWatermark = NO;
        _tintColor = RGBToColor(2,212,225,1);
        _bottomPanelHeight = 160;
        _cameraPosition = QupaiSDKCameraPositionBack;
        _qupaiSDK = self;
        return self;
    }
    return nil;
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resignActiveNotification:(NSNotification *)notification
{
    if(![self.recordVideo isEmpty]){
        [self.recordVideo synchronizeToDisk];
        QPSave.shared.draftVideoPackName = self.recordVideo.packName;
        [QPSave.shared save];
    }else{
        if (QPSave.shared.draftVideoPackName) {
            QPSave.shared.draftVideoPackName = nil;
            [QPSave.shared save];
        }
    }
    [[QPEventManager shared] uploadEvents];
}

- (void)compelete:(NSString *)path thumbnailPath:(NSString *)thumbnailPath
{
    if (path) {
        [[QPEventManager shared] event:QPEventRecordFinish
                            withParams:@{@"duration" :[NSNumber numberWithInt:self.recordVideo.duration * 1000],
                                         @"maxDuration":[NSNumber numberWithInt:[QupaiSDK shared].maxDuration * 1000]}];    // 记录事件
    }

    [self removeNotification];
    _watermarkImage = nil;
    [_delegte qupaiSDK:self compeleteVideoPath:path thumbnailPath:thumbnailPath];
    QPSave.shared.draftVideoPackName = nil;
    self.recordVideo = nil;
    [[QPSave shared] save];
}

- (UIViewController *)createRecordViewController
{
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self addNotification];
    [self clearRecordCache];
    
    QPVideo *video = nil;
    BOOL videoIsDraft = NO;
    BOOL videoNeedToEffectView = NO;
    if (QPSave.shared.draftVideoPackName) {
        video = [[QPVideo alloc] initWithPack:[QPVideo videoFullPathForVideoPackName:QPSave.shared.draftVideoPackName]];
        videoIsDraft = YES;
        videoNeedToEffectView = video.recordFileName != nil;
    }else {
       video = [[QPVideo alloc] init];
    }
    [video setupMinDuration:_minDuration maxDuration:_maxDuration bitRate:_bitRate];
    
    QPRecordViewController *controller = [[QPRecordViewController alloc] initWithNibName:@"QPRecordViewController" bundle:nil video:video];
    controller.videoIsDraft = videoIsDraft;
    controller.videoNeedToEffectView = videoNeedToEffectView;
    self.recordVideo = video;
    // 上传应用信息
//    [self uploadAppInfo];
    [self uploadUsageInfo];
    [[QPEventManager shared] event:QPEventStart];
    
    return controller;
}

- (UIViewController *)createRecordViewControllerWithMinDuration:(CGFloat)minDuration
                                                    maxDuration:(CGFloat)maxDuration
                                                        bitRate:(CGFloat)bitRate{
    _minDuration = minDuration;
    _maxDuration = maxDuration;
    _bitRate     = bitRate;
    return [self createRecordViewController];
}

- (UIViewController *)createRecordViewControllerWithMinDuration:(CGFloat)minDuration
                                                    maxDuration:(CGFloat)maxDuration
                                                        bitRate:(CGFloat)bitRate
                                                      videoSize:(CGSize)videoSize{
    _minDuration = minDuration;
    _maxDuration = maxDuration;
    _bitRate     = bitRate;
    _videoSize   = videoSize;
    return [self createRecordViewController];
}

//- (UIViewController *)createRecordViewControllerWithMaxDuration:(CGFloat)maxDuration
//                                                        bitRate:(CGFloat)bitRate
//                                    thumbnailCompressionQuality:(CGFloat)thumbnailCompressionQuality
//                                                 watermarkImage:(UIImage *)watermarkImage
//                                              watermarkPosition:(QupaiSDKWatermarkPosition)watermarkPosition
//                                                enableMoreMusic:(BOOL)enableMoreMusic
//                                                   enableImport:(BOOL)enableImport
//{
//    _maxDuration = maxDuration;
//    _bitRate     = bitRate;
//    _thumbnailCompressionQuality = thumbnailCompressionQuality;
//    _watermarkPosition = watermarkPosition;
//    self.watermarkImage = watermarkImage;
//    _enableMoreMusic   = enableMoreMusic;
//    _enableImport      = enableImport;
//    _enableVideoEffect = YES;
//    _tintColor         = RGBToColor(0,204,170,1);
//    return [self createRecordViewController];
//}
//
//
//- (UIViewController *)createRecordViewControllerWithMaxDuration:(CGFloat)maxDuration
//                                                        bitRate:(CGFloat)bitRate
//                                    thumbnailCompressionQuality:(CGFloat)thumbnailCompressionQuality
//                                                 watermarkImage:(UIImage *)watermarkImage
//                                              watermarkPosition:(QupaiSDKWatermarkPosition)watermarkPosition
//                                                enableMoreMusic:(BOOL)enableMoreMusic
//                                                   enableImport:(BOOL)enableImport
//                                                enableVideoEffect:(BOOL)videoEffect
//{
//    _maxDuration = maxDuration;
//    _bitRate     = bitRate;
//    _thumbnailCompressionQuality = thumbnailCompressionQuality;
//    _watermarkPosition = watermarkPosition;
//    self.watermarkImage = watermarkImage;
//    _enableMoreMusic   = enableMoreMusic;
//    _enableImport      = enableImport;
//    _enableVideoEffect  = videoEffect;
//    _tintColor         = RGBToColor(0,204,170,1);
//    return [self createRecordViewController];
//}
//
//- (UIViewController *)createRecordViewControllerWithMaxDuration:(CGFloat)maxDuration
//                                                        bitRate:(CGFloat)bitRate
//                                    thumbnailCompressionQuality:(CGFloat)thumbnailCompressionQuality
//                                                 watermarkImage:(UIImage *)watermarkImage
//                                              watermarkPosition:(QupaiSDKWatermarkPosition)watermarkPosition
//                                                      tintColor:(UIColor *)tintColor
//                                                enableMoreMusic:(BOOL)enableMoreMusic
//                                                   enableImport:(BOOL)enableImport
//                                              enableVideoEffect:(BOOL)videoEffect
//{
//    _maxDuration = maxDuration;
//    _bitRate     = bitRate;
//    _thumbnailCompressionQuality = thumbnailCompressionQuality;
//    _watermarkPosition = watermarkPosition;
//    self.watermarkImage = watermarkImage;
//    _enableMoreMusic   = enableMoreMusic;
//    _enableImport      = enableImport;
//    _enableVideoEffect  = videoEffect;
//    _tintColor         = tintColor;
//    return [self createRecordViewController];
//}


- (void)clearRecordCache
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *videoFullPath = [QPVideo videoFullPathForVideoPackName:nil];
    NSArray *packList = [fm contentsOfDirectoryAtPath:videoFullPath error:&error];
    for (NSString *pack in packList) {
        if (![QPSave.shared.draftVideoPackName isEqualToString:pack]) {
            NSString *filePath = [videoFullPath stringByAppendingPathComponent:pack];
            [fm removeItemAtPath:filePath error:&error];
        }
    }
}

- (void)setWatermarkImage:(UIImage *)watermarkImage
{
    if (watermarkImage) {
        self.enableWatermark = YES;
    }else{
        self.enableWatermark = NO;
    }
    _watermarkImage = [self createPictureImageByImage:watermarkImage];
}

- (UIImage *)createPictureImageByImage:(UIImage *)image
{
    CGFloat bw=640, bh=640, w = image.size.width, h = image.size.height, cap = 14;
    void *data = calloc(bw * bh * 4, 1);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, bw, bh, 8, bw * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    if (_watermarkPosition == QupaiSDKWatermarkPositionTopRight) {
        CGContextDrawImage(context, CGRectMake(bw-w-cap, bh-h-cap, w, h), image.CGImage);
    }else{
        CGContextDrawImage(context, CGRectMake(bw-w-cap, cap, w, h), image.CGImage);
    }
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(data);
    
    UIImage *circleImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return circleImage;
}

- (void)updateMoreMusic
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:QPMoreMusicUpdateNotification object:nil];
}

- (void)setMaxDuration:(CGFloat)maxDuration
{
    _maxDuration = MAX(MIN(maxDuration, MAXFLOAT), 8);
}
    
    
#pragma mark - info

- (NSString *)appName 
{
    NSString *appName=[[[NSBundle mainBundle] infoDictionary]  objectForKey:(id)kCFBundleNameKey];
    return appName;
}

-(QPVideoRatio)videoRatio {
    float aspects[5] = {9/16.0, 3/4.0, 1.0, 4/3.0,16/9.0};
    float videoAspect = _videoSize.width/_videoSize.height;
    int index = 0;
    for (int i=0; i<5; i++) {
        index = i;
        if (videoAspect <= aspects[i]) break;
    }
    if (index>0) {
        if (fabsf(videoAspect-aspects[index]) > fabsf(videoAspect-aspects[index-1])) {
            index = index-1;
        }
    }
    return index;
}

#pragma mark - upload info

-(void)uploadAppInfo{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *urlString = [NSString stringWithFormat:@"http://cms.danqoo.com/duanqu.manager/sdk.do?app&appName=%@&platform=0",
                           [appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"error");
        }
    }];
}

#pragma mark - upload info

- (void)uploadUsageInfo {
    if (![QPSave shared].sdkLaunched) {
        [[QPEventManager shared] uploadAppInfo];
    }
    [[QPEventManager shared] uploadEvents];
}

@end

