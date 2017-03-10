//
//  QPCutViewController.m
//  QupaiSDK
//
//  Created by lyle on 14-3-17.
//  Copyright (c) 2014年 lyle. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "QPCutViewController.h"
#import "QPCutThumbnailCell.h"
#import "QPCutBarView.h"
#import "QPCutInfo.h"
#import "QPVideoPoint.h"
#import "QPProgressHUD.h"
#import "QPCutCenterProgressView.h"
#import "QupaiSDK.h"
#import "QPGuideFactory.h"
#import "QPEventManager.h"

#import <QPSDKCore/QPVideoEditor.h>

#import "QPCutView.h"

static NSString *const CutInfoStartTimeKeyPath = @"_cutInfo.startTime";
static NSString *const CutInfoEndTimeKeyPath = @"_cutInfo.endTime";
static NSString *const CutInfoOffsetTimeKeyPath = @"_cutInfo.offsetTime";
static NSString *const AVPlayerRateKeyPath = @"_avPlayer.rate";

static const CGFloat UpNeedleAdjust = 0.03;


typedef NS_ENUM(NSInteger, QPCutPresetQuality) {
    QPCutPresetQualityLow = 4,
    QPCutPresetQualityMedium = 6,
    QPCutPresetQualityHigh = 8
};

@interface QPCutViewController ()<QPCutViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource>
{
    AVPlayer *_avPlayer;
    AVPlayerLayer *_playerLayer;
    NSMutableArray *_imagesArray;
    
    NSTimer *_cutTimer;
//    QPCutVideo *_cutVideo;
    QPVideoEditor *_videoEditor;
    
    QPCutInfo *_cutInfo;
    QPCutBarView *_cutBarView;
    QPCutCenterProgressView *_cutCenterProgressView;
    
    AVAssetImageGenerator *_generator;
    
    UIView *_guideDragTime;
    UIView *_guideDragVideo;
    
    __block BOOL _isSeek;
    
    CGRect _guideRect;
    BOOL _addObserver;
    
    CGRect _playerFillFrame;
    CGSize _videoSize;
    BOOL _squareVideoSize;
}

@property (nonatomic, strong) NSArray *observableKeys;

@property (nonatomic, strong) QPCutView *qpCutView;

@end

@implementation QPCutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil cutInfo:(QPCutInfo *)cutInfo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _cutInfo = cutInfo;
    }
    return self;
}

- (void)loadView {
    self.qpCutView = [[QPCutView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.qpCutView.delegate = self;
    self.view = self.qpCutView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadProgressView];
    [self addGesture];
    
    CGFloat n = ceilf(_cutInfo.videoDuration);
    CGFloat t = _cutInfo.videoDuration;
    CGFloat x = (ScreenWidth*t)/(8 * n);
    //    [self.qpCutView.collectionView registerNib:[UINib nibWithNibName:@"QPCutThumbnailCell" bundle:[QPBundle mainBundle]] forCellWithReuseIdentifier:@"QPCutThumbnailCell"];
    [self.qpCutView.collectionView registerClass:[QPCutThumbnailCell class] forCellWithReuseIdentifier:@"QPCutThumbnailCell"];
    self.qpCutView.collectionView.delegate = self;
    self.qpCutView.collectionView.dataSource = self;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.qpCutView.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(x, 40);
    
    _cutBarView = [[QPCutBarView alloc] initWithFrame:CGRectMake(0, 88, ScreenWidth, 80) cutInfo:_cutInfo];
    [self.qpCutView.viewBottom addSubview:_cutBarView];
    self.qpCutView.activityNext.hidden = YES;
    self.qpCutView.labelCutMiddle.textColor = [QupaiSDK shared].tintColor;
    self.qpCutView.buttonCut.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    _squareVideoSize = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_cutInfo.asset) {
        [[QPProgressHUD sharedInstance] showtitleNotic:@"视频不存在"];
        [self onClickButtonBackAction:nil];
        return;
    }
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:_cutInfo.asset];
    [self setAVPlayerByPlayerItem:item];
    [self generateImageByAVAsset:_cutInfo.asset];
    [self refreshViewLayout];
    [self addStausObserver];
}

- (void)stopPlayAndReset
{
    _cutInfo.playTime = -1.0;/*隐藏 播放进度条*/
    [self endTimer];
    [self refreshViewLayout];
    [self removeDragTimeGuide];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopPlayAndReset];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeBaseDir];
}

- (void)loadProgressView
{
    _cutCenterProgressView = [[QPCutCenterProgressView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 46)];
    _cutCenterProgressView.colorBg = [UIColor whiteColor];
    _cutCenterProgressView.colorNomal = [UIColor clearColor];;
    _cutCenterProgressView.colorSelect = [QupaiSDK shared].tintColor;
    [self.qpCutView.viewProgress addSubview:_cutCenterProgressView];
    
    _cutCenterProgressView.startTime = (_cutInfo.startTime  + UpNeedleAdjust)/_cutInfo.cutMaxDuration;
    _cutCenterProgressView.endTime = (_cutInfo.endTime  - UpNeedleAdjust)/ _cutInfo.cutMaxDuration;
}

- (void)dealloc
{
    [self removeStatusObserver];
    [self cancelGenerator];
}

#pragma mark - KVO

- (NSArray *)observableKeys
{
    if (_observableKeys == nil) {
        _observableKeys = @[CutInfoStartTimeKeyPath, CutInfoEndTimeKeyPath,
                            CutInfoOffsetTimeKeyPath,AVPlayerRateKeyPath];
    }
    return _observableKeys;
}

- (void)addStausObserver
{
    if (_addObserver) {
        return;
    }
    _addObserver = YES;
    for (NSString *keyPath in self.observableKeys) {
        [self addObserver:self forKeyPath:keyPath options:
         NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)removeStatusObserver
{
    if (!_addObserver) {
        return;
    }
    _addObserver = NO;
    for (NSString *keyPath in self.observableKeys) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![self.observableKeys containsObject:keyPath]) {
        [super observeValueForKeyPath:keyPath ofObject:self change:change context:context];
        return;
    }else if([AVPlayerRateKeyPath isEqualToString:keyPath]){
        self.qpCutView.imageViewPlayFlag.hidden = _avPlayer.rate != 0.0;
    }else{
        _cutInfo.dragRight = [CutInfoEndTimeKeyPath isEqualToString:keyPath];
        [self stopPlayAndReset];
    }
}

- (void)refreshViewLayout
{
    CGFloat leftTime = _cutInfo.offsetTime + _cutInfo.startTime;
    self.qpCutView.labelCutLeft.text = [NSString stringWithFormat:@"%02d:%02d",(int)(leftTime + 0.4999)/60, (int)(leftTime + 0.4999)%60];
    
    CGFloat rightTime = _cutInfo.offsetTime + _cutInfo.endTime;
    self.qpCutView.labelCutRight.text = [NSString stringWithFormat:@"%02d:%02d",(int)(rightTime + 0.4999)/60, (int)(rightTime + 0.4999)%60];
    
    self.qpCutView.labelCutMiddle.text = [NSString stringWithFormat:@"%0.1f",_cutInfo.endTime - _cutInfo.startTime];
    
    [self avplayerFromTime:_cutInfo.dragRight ? rightTime : leftTime toTime:0 play:NO];
    
    
    //    [_pointProgress.array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        VideoPoint *vp = (VideoPoint *)obj;
    //        if (idx == 0) {
    //            vp.startTime = 0;
    //            vp.endTime = _cutInfo.startTime + UpNeedleAdjust;
    //        }else if(idx == 1){
    //            vp.startTime = _cutInfo.startTime + UpNeedleAdjust;
    //            vp.endTime = _cutInfo.endTime - UpNeedleAdjust;
    //        }
    //    }];
    //    [_pointProgress updateProgress:0];
    
    _cutCenterProgressView.startTime = (_cutInfo.startTime  + UpNeedleAdjust)/_cutInfo.cutMaxDuration;
    _cutCenterProgressView.endTime = (_cutInfo.endTime  - UpNeedleAdjust)/ _cutInfo.cutMaxDuration;
    [_cutCenterProgressView updateProgress:0];
}

#pragma mark - Cut Directory

- (NSString *)baseDir
{
    NSString *dir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"cut_thumb"];
    [[NSFileManager defaultManager]createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

- (NSString *)newUniquePath
{
    return [[[self baseDir] stringByAppendingPathComponent:[self uuid]] stringByAppendingPathExtension:@"png"];
}

- (NSString *)defaultCutVideoPath
{
    return [[NSTemporaryDirectory() stringByAppendingPathComponent:@"cut_video"] stringByAppendingPathExtension:@"mp4"];
}

- (NSString*) uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

- (void)removeBaseDir
{
    [[NSFileManager defaultManager] removeItemAtPath:[self baseDir] error:nil];
}

#pragma mark - Thumail

-(void)generateImageByAVAsset:(AVAsset *)asset
{
    if (!asset) {
        return;
    }
    CMTime duration = [asset duration];
    CMTime startTime = kCMTimeZero;
    NSMutableArray *array = [NSMutableArray array];
    
    CMTime addTime = CMTimeMake(1000,1000);
    if (_cutInfo.cutMaxDuration > 2.0) {
        CGFloat d = _cutInfo.cutMaxDuration / 8.0;
        addTime = CMTimeMakeWithSeconds(d, 1000);
    }
    while (CMTIME_COMPARE_INLINE(startTime, <, duration)) {
        [array addObject:[NSValue valueWithCMTime:startTime]];
        startTime = CMTimeAdd(startTime, addTime);
    }
    _generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    _generator.appliesPreferredTrackTransform=TRUE;
    
    CGFloat frameRate = 30.0;
    NSError *error = nil;
    CGPoint offset = CGPointZero;
    CGSize size = CGSizeMake(200, 200);
    NSArray *instructions = [self instructionWithAsset:asset outFrameRate:&frameRate offset:offset toSize:size error:&error];
    
    if (frameRate > 30) {
        AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:asset];
        videoComposition.instructions = instructions;
        videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0/30, 10000);
        videoComposition.renderSize = size;
        _generator.videoComposition = videoComposition;
    }
  
    __block __weak QPCutViewController *wself = self;
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *image = [UIImage imageWithCGImage:im];
            NSData *data = UIImagePNGRepresentation(image);
            NSString *path = [wself newUniquePath];
            [data writeToFile:path atomically:YES];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [wself addThumbnail:path];
            });
        }else{
            NSLog(@"genset failed");
        }
    };
        _generator.maximumSize = CGSizeMake(200, 200);
    [_generator generateCGImagesAsynchronouslyForTimes:array completionHandler:handler];
}

- (NSArray *)instructionWithAsset:(AVAsset*)asset outFrameRate:(CGFloat *)frameRate offset:(CGPoint)_offset  toSize:(CGSize)size error:(NSError **)error
{
    AVAssetTrack *assetTrackVideo;
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetTrackVideo = [asset tracksWithMediaType:AVMediaTypeVideo][0];
        
        *frameRate = assetTrackVideo.nominalFrameRate;
    }
    NSMutableArray *instructions = [[NSMutableArray alloc] init];
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:assetTrackVideo];
    
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    instruction.layerInstructions = @[layerInstruction];
    [instructions addObject:instruction];
    
    if (assetTrackVideo) {
        float sw = assetTrackVideo.naturalSize.width, sh = assetTrackVideo.naturalSize.height;
        float dw = size.width, dh = size.height, ox = 0, oy = 0, rotate = 0;
        
        float rw = dw / sw;
        float rh = dh / sh;
        if (rw > rh) {
            rh = dh / sw;
        }else{
            rw = dw / sh;
        }
        //ox = (dw - sw * rw) * 0.5; oy = (dh - sh * rh) * 0.5;
        
        CGAffineTransform trackTrans = assetTrackVideo.preferredTransform;
        if (trackTrans.b == 1 && trackTrans.c == -1) {//90 ang
            rotate = M_PI_2;
            ox = sh * rh * _offset.x * -1 + dw;
            oy = sw * rw * _offset.y * -1;
        }else if (trackTrans.a == -1 && trackTrans.d == -1) {//180 ang
            rotate = M_PI;
            ox = sw * rw * (1 - _offset.x);
            oy = sh * rh * _offset.y + dh;
        }else if (trackTrans.b == -1 && trackTrans.c == 1) {//270 ang
            rotate = M_PI_2 * 3;
            ox = sh * rh * _offset.x * -1;
            oy = sw * rw * (1 - _offset.y);
        }else{
            ox = sw * rw * _offset.x * -1;
            oy = sh * rh * _offset.y * -1;
        }
        CGAffineTransform transform = CGAffineTransformMakeRotation(rotate);
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(rw, rh));
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(ox, oy));
        [layerInstruction setTransform:transform atTime:kCMTimeZero];
    }
    return instructions;
}

- (void)cancelGenerator
{
    if (_generator) {
        [_generator cancelAllCGImageGeneration];
    }
}

- (void)addThumbnail:(NSString *)path
{
    if (!_imagesArray) {
        _imagesArray = [NSMutableArray arrayWithCapacity:16];
    }
    if (path) {
        [_imagesArray addObject:path];
    }
    
    if (!self.qpCutView.collectionView.isDecelerating && !self.qpCutView.collectionView.isDragging){
        NSArray *array = [self.qpCutView.collectionView visibleCells];
        for (QPCutThumbnailCell *cell in array) {
            if (cell.imageViewIcon.image == nil) {
                NSIndexPath *indexPath = [self.qpCutView.collectionView indexPathForCell:cell];
                if (indexPath.row < _imagesArray.count) {
                    [self.qpCutView.collectionView reloadData];
                    break;
                }
            }
        }
    }
}

- (void)setAVPlayerByPlayerItem:(AVPlayerItem *)item
{
    if (_avPlayer == nil) {
        CGRect rect = [self videoFitRectByAVAsset:item.asset];
        _playerFillFrame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        _avPlayer = [AVPlayer playerWithPlayerItem:item];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
        _playerLayer.frame = _playerFillFrame;
        //        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        self.qpCutView.scrollViewPlayer.frame = [self cropViewFitRect];
        self.qpCutView.scrollViewPlayer.center = CGPointMake(ScreenWidth/2.0, ScreenWidth/2.0);
        self.qpCutView.scrollViewPlayer.contentSize = rect.size;
        [self.qpCutView.scrollViewPlayer.layer addSublayer:_playerLayer];
        [self.qpCutView.scrollViewPlayer setContentOffset:rect.origin];
        
        self.qpCutView.scrollViewPlayer.transform = CGAffineTransformMakeScale(ScreenWidth/240.0, ScreenWidth/240);
        
        [self checkGuideView:rect];
        
        _guideRect = rect;//保存到下一步使用
    }
}

#pragma mark - Guide

- (void)checkGuideView:(CGRect)rect
{
    if (rect.size.width == rect.size.height){
        return;
    }
    if (![[QPSave shared] cutDragGuide]){
        [QPSave shared].cutDragGuide = YES;
        if (rect.size.width != rect.size.height) {
            _guideDragVideo = [QPGuideFactory createDragVideo];
            _guideDragVideo.center = CGPointMake(CGRectGetWidth(self.qpCutView.viewCenter.bounds)/2.0, CGRectGetHeight(self.qpCutView.viewCenter.bounds)/2.0);
            [self.qpCutView.viewCenter addSubview:_guideDragVideo];
            //            _guideDragTextView = [QPGuideFactory createDragText];
            //            _guideDragTextView.center = CGPointMake(CGRectGetWidth(_viewCenter.bounds)/2.0, CGRectGetHeight(_guideDragTextView.bounds)/2.0);
            //            [_viewCenter addSubview:_guideDragTextView];
        }
        
    }
}


- (void)removeGuideImgView
{
    [self removeDragTimeGuide];
    [self removeDragVideoGuide];
}

- (void)removeDragVideoGuide
{
    if (_guideDragVideo) {
        [_guideDragVideo removeFromSuperview];
        _guideDragVideo = nil;
    }
}

- (void)removeDragTimeGuide
{
    if (_guideDragTime) {
        [_guideDragTime removeFromSuperview];
        _guideDragTime = nil;
    }
}

#pragma mark - Gesture
- (void)addGesture
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.enabled = YES;
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
    [self.qpCutView.scrollViewPlayer addGestureRecognizer:singleTapGestureRecognizer];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    if (_avPlayer.rate == 1.0) {
        [_avPlayer pause];
        [self endTimer];
    }else{
        [self startTimer];
        
        if (_cutInfo.playTime == -1.0) {
            CGFloat playTime = _cutInfo.offsetTime + _cutInfo.startTime;
            _cutInfo.playTime = playTime;
            [self avplayerFromTime:playTime toTime:0 play:YES];
        }else{
            [_avPlayer play];
        }
    }
}

#pragma mark - Timer
- (void)startTimer
{
    [self endTimer];
    _cutTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self
                                               selector:@selector(cutUpdateProgress:) userInfo:nil repeats:YES];
}

- (void)endTimer
{
    [_cutTimer invalidate];
    _cutTimer = nil;
}

- (void)cutUpdateProgress:(CMTime *)timer
{
    CGFloat playTime = [self avplayerCuttentTime];
    if (_cutInfo.startTime + _cutInfo.offsetTime <= playTime &&
        playTime <= _cutInfo.endTime + _cutInfo.offsetTime &&
        playTime > _cutInfo.playTime) {
        _cutInfo.playTime = playTime;
    }
    if (playTime >= _cutInfo.offsetTime + _cutInfo.endTime) {
        [_avPlayer pause];
        [self endTimer];
        _cutInfo.playTime = -1.0;
        
        [self avplayerFromTime:_cutInfo.offsetTime + _cutInfo.startTime toTime:0 play:NO];
    }
}
#pragma mark - Action

-(void)onClickButtonBackAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onClickButtonNextAction:(UIButton *)sender {
    [self finishCutVideo];
}

- (void)onClickButtonCutAction:(UIButton *)sender {
    if (sender.isSelected) {
        // 当前 1:1
        _playerLayer.frame = self.qpCutView.scrollViewPlayer.bounds;
    } else {
        // not 1:1
        _playerLayer.frame = _playerFillFrame;
    }
    
    [sender setSelected:!sender.isSelected];
    _squareVideoSize = sender.isSelected;
    //    self.qpCutView.scrollViewPlayer.contentSize = self.qpCutView.scrollViewPlayer.bounds.size;
    
}

- (void)finishCutVideo
{
    self.qpCutView.buttonNext.hidden = YES;
    [self.qpCutView.activityNext startAnimating];
    self.qpCutView.buttonBack.enabled = NO;
    
    [_avPlayer pause];
    self.qpCutView.viewCenter.userInteractionEnabled = NO;
    self.qpCutView.viewBottom.userInteractionEnabled = NO;
    
    [self cancelGenerator];
    [self endTimer];
    
    CGFloat startTime = _cutInfo.startTime + _cutInfo.offsetTime;
    CGFloat endTime = _cutInfo.endTime + _cutInfo.offsetTime;
    
    NSString *outputURL = [self defaultCutVideoPath];
    NSURL *toURL = [NSURL fileURLWithPath:outputURL];
    [[NSFileManager defaultManager] removeItemAtURL:toURL error:nil];
    CMTimeRange range = CMTimeRangeMake(CMTimeMakeWithSeconds(startTime, 1000), CMTimeMakeWithSeconds(endTime-startTime, 1000));
    
//    _cutVideo = [QPCutVideo alloc];
    _videoEditor = [[QPVideoEditor alloc] init];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // TODO 不进合成页面加水印
//    if (![QupaiSDK shared].enableVideoEffect && [QupaiSDK shared].enableWatermark) {//如果不进合成页面而且有水印，剪裁的时候直接加水印
//        [_cutVideo cutVideoAVAsset:_cutInfo.asset range:range waterMark:[QupaiSDK shared].watermarkImage offset:[self offsetVideo] size:[QPSDKConfig videoSize] presetName:AVAssetExportPresetMediumQuality toURL:toURL completeBlock:^(NSURL *filePath) {
//            [UIApplication sharedApplication].idleTimerDisabled = NO;
//            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
//                [_delegate cutViewControllerFinishCut:filePath.path];
//            }else{
//                NSLog(@"导出 失败");
//                [[QPProgressHUD sharedInstance] showtitleNotic:@"导出失败!"];
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//        }];
//    }else{
//        [_cutVideo cutVideoAVAsset:_cutInfo.asset range:range offset:[self offsetVideo]
//                              size:[self sizeVideo] presetName:AVAssetExportPresetHighestQuality toURL:toURL completeBlock:^(NSURL *filePath) {
//                                  [UIApplication sharedApplication].idleTimerDisabled = NO;
//                                  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
//                                      [_delegate cutViewControllerFinishCut:filePath.path];
//                                  }else{
//                                      NSLog(@"导出 失败");
//                                      [[QPProgressHUD sharedInstance] showtitleNotic:@"导出失败!"];
//                                      [self.navigationController popViewControllerAnimated:YES];
//                                  }
//                              }];
    CGSize outputSize = [self sizeVideo];
    NSInteger bitRate = outputSize.width * outputSize.height * QPCutPresetQualityMedium;
    [_videoEditor exportVideoAVAsset:_cutInfo.asset range:range rect:[self cutRect] size:outputSize bitRate:bitRate toURL:toURL percentBlock:^(CGFloat percent) {
        NSLog(@"cut percent %f", percent);
    } completeBlock:^(NSURL *filePath) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
            [_delegate cutViewControllerFinishCut:filePath.path];
        }else{
            [[QPProgressHUD sharedInstance] showtitleNotic:@"导出失败!"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
//        _cutVideo.delegate = self;
//
//        [_cutVideo cutVideoAndCompressAVAsset:_cutInfo.asset range:range offset:[self offsetVideo] waterMark:[QupaiSDK shared].watermarkImage size:[self sizeVideo] bitrate:400000 presetName:AVAssetExportPresetHighestQuality toURL:toURL];
//    }
    [[QPEventManager shared] event:QPEventImportCutOk];
}

//#pragma mark QPCutVideoDelegate
//
//- (void)cutAndCompressVideoSuccess:(NSURL *)fileURL {
//    
//    NSLog(@"视频路径%@", fileURL.path);
////    UISaveVideoAtPathToSavedPhotosAlbum(fileURL.path, nil, nil, nil);
//  [_delegate cutViewControllerFinishCut:fileURL.path];
//}
//
//
//- (void)cutAndCompressVideofailure:(NSError *)error {
//    
//    NSLog(@"视频裁剪合成失败%@", error);
//}
//
//
//- (void)currentCompressPlan:(CGFloat)plan {
//    
//    NSLog(@"当前视频合成进度:%f", plan);
//    
//}


- (void)buttonGuideImageViewClick:(id)sender
{
}
#pragma mark - Calc

- (void)loadVideoInfo
{
    
}

- (CGRect)videoFitRectByAVAsset:(AVAsset *)asset {
    CGRect cropRect = [self cropViewFitRect];
    AVAssetTrack *assetTrackVideo;
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetTrackVideo = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    
    // new
    CGSize naturalSize = assetTrackVideo.naturalSize;
    _videoSize = naturalSize;
    CGAffineTransform trackTrans = assetTrackVideo.preferredTransform;
    if ((trackTrans.b == 1 && trackTrans.c == -1)||(trackTrans.b == -1 && trackTrans.c == 1)) {//90 ang
        _videoSize = CGSizeMake(naturalSize.height, naturalSize.width);
    }
    
    CGFloat cropRatio = CGRectGetWidth(cropRect)/CGRectGetHeight(cropRect);
    CGFloat sizeRatio = _videoSize.width/_videoSize.height;
    CGFloat destWidth, destHeight, offsetX, offsetY;
    
    if (sizeRatio > cropRatio) {            // 视频比裁剪区域宽
        destHeight = CGRectGetHeight(cropRect);
        destWidth = destHeight * sizeRatio;
        offsetY = 0;
        offsetX = (destWidth - CGRectGetWidth(cropRect))/2;
    }else {                                 // 视频比裁剪区域长
        destWidth = CGRectGetWidth(cropRect);
        destHeight = destWidth / sizeRatio;
        offsetX = 0;
        offsetY = (destHeight - CGRectGetHeight(cropRect))/2;
    }
    return CGRectMake(offsetX, offsetY, destWidth, destHeight);
    
    // old
//    float sw = assetTrackVideo.naturalSize.width, sh = assetTrackVideo.naturalSize.height;
//    float dw = 240, dh = 240, ox = 0, oy = 0, rotate = 0,fw = 0, fh = 0;
//    
//    float rw = dw / sw;
//    float rh = dh / sh;
//    if (rw > rh) {
//        rh = dh / sw;
//    }else{
//        rw = dw / sh;
//    }
//    fw = sw * rw;
//    fh = sh * rh;
//    ox = (fw - dw) * 0.5;
//    oy = (fh - dh) * 0.5;
//    CGAffineTransform trackTrans = assetTrackVideo.preferredTransform;
//    if (trackTrans.b == 1 && trackTrans.c == -1) {//90 ang
//        rotate = M_PI_2;
//        CGFloat t = ox;
//        ox = oy;
//        oy = t;
//        
//        t = fw;
//        fw = fh;
//        fh = t;
//        _videoSize = CGSizeMake(_videoSize.height, _videoSize.width);
//    }else if (trackTrans.b == -1 && trackTrans.c == 1) {//270 ang
//        rotate = M_PI_2 * 3;
//        CGFloat t = ox;
//        ox = oy;
//        oy = t;
//        
//        t = fw;
//        fw = fh;
//        fh = t;
//        _videoSize = CGSizeMake(_videoSize.height, _videoSize.width);
//    }
//    return CGRectMake(ox, oy, fw, fh);
}

- (CGRect)cropViewFitRect {
    CGSize videoSize =  [QupaiSDK shared].videoSize;
    CGFloat ratio = videoSize.width/videoSize.height;
    if (ratio > 1) {
        return CGRectMake(0, 0, 240, 240/ratio);
    }else {
        return CGRectMake(0, 0, 240*ratio, 240);
    }
}

//- (CGPoint)offsetVideo
//{
//    if (_squareVideoSize) {
//        CGSize s = self.qpCutView.scrollViewPlayer.contentSize;
//        CGPoint p = self.qpCutView.scrollViewPlayer.contentOffset;
//        return CGPointMake(p.x/s.width, p.y/s.height);
//    }else {
//        return CGPointMake(0, 0);
//    }
//
//}

- (CGRect)cutRect{
//    if (_squareVideoSize) {
        CGSize sourceSize = self.qpCutView.scrollViewPlayer.contentSize;
        CGPoint offsetPoint = self.qpCutView.scrollViewPlayer.contentOffset;
        CGSize cutSize = [self cropViewFitRect].size;
        return CGRectMake(offsetPoint.x/sourceSize.width, offsetPoint.y/sourceSize.height, cutSize.width/sourceSize.width, cutSize.height/sourceSize.height);
//    }else {
//        return CGRectMake(0, 0, 1, 1);
//    }
}

- (CGSize)sizeVideo {
//    if (_squareVideoSize) {
        return [QupaiSDK shared].videoSize;
//    }else {
//        return _videoSize;
//    }
}

#pragma mark - AVPlayer

- (CGFloat)avplayerProgress
{
    CGFloat play = [self avplayerCuttentTime];
    CGFloat sum  = [self avplayerDuration];
    return sum == 0 ? 0 : play/sum;
}

- (CGFloat)avplayerCuttentTime
{
    CGFloat cur = CMTimeGetSeconds(_avPlayer.currentTime);
    NSLog(@"play time = %f",cur);
    return isnan(cur) ? 0 : cur;
}

- (CGFloat)avplayerDuration
{
    CGFloat dur = CMTimeGetSeconds([_avPlayer.currentItem duration]);
    return  isnan(dur) ? 0 : dur;
}

- (void)setTableViewProgress:(CGFloat)progress
{
    CGFloat y = self.qpCutView.collectionView.contentSize.height * progress - 160;
    CGPoint point = CGPointMake(0, y);
    [self.qpCutView.collectionView setContentOffset:point animated:NO];
}

- (void)avplayerFromTime:(CGFloat)fromTime toTime:(CGFloat)toTime play:(BOOL)play
{
    //NSLog(@"%f",fromTime);
    if (fromTime < 0) {
        return;
    }
    if (!_isSeek && _avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        _isSeek = YES;
        __weak QPCutViewController *wself = self;
        //NSLog(@"seek to time %f  %f",fromTime, CMTimeGetSeconds(CMTimeMake(fromTime * 1000, 1000)));
        [_avPlayer seekToTime:CMTimeMake(fromTime * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                [wself finishSeek:play];
            }
            //NSLog(@"play %d %d",finished,play);
        }];
    }
}

- (void)finishSeek:(BOOL)play
{
    if (play) {
        [_avPlayer play];
    }else{
        [_avPlayer pause];
    }
    _isSeek = NO;
}

- (CGFloat)offsetTime
{
    CGFloat y = self.qpCutView.collectionView.contentOffset.x;
    CGFloat w = self.qpCutView.collectionView.contentSize.width;
    CGFloat r = y/w;
    CGFloat time = r * _cutInfo.videoDuration;
    return time;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _cutInfo.thumbnailCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QPCutThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QPCutThumbnailCell" forIndexPath:indexPath];
    if (indexPath.row < _imagesArray.count) {
        cell.imageViewIcon.image = [UIImage imageWithContentsOfFile:_imagesArray[indexPath.row]];
    }else{
        cell.imageViewIcon.image = nil;
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.qpCutView.collectionView) {
        [self removeDragVideoGuide];
        return;
    }
    [self removeDragTimeGuide];
    
    CGFloat offset = [self offsetTime];
    // 偏移量超过极限值，让偏移量等于极限值
    if (offset > _cutInfo.videoDuration - _cutInfo.cutMaxDuration) {
        offset = _cutInfo.videoDuration - _cutInfo.cutMaxDuration - 0.00001; // 防止大于视频长度导致出错
    }else if(offset < 0){
        offset = 0;
    }
    if (offset >= 0 && _cutInfo.videoDuration - offset >= _cutInfo.cutMaxDuration) {
        _cutInfo.offsetTime = offset;
        [self avplayerFromTime:_cutInfo.offsetTime + _cutInfo.startTime toTime:0 play:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        if (scrollView != self.qpCutView.collectionView) {
            [self removeDragVideoGuide];
        }else{
            [self removeDragTimeGuide];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView != self.qpCutView.collectionView) {
        [self removeDragVideoGuide];
    }else{
        [self removeDragTimeGuide];
    }
    
    CGFloat offset = [self offsetTime];
    // 偏移量超过极限值，让偏移量等于极限值
    if (offset > _cutInfo.videoDuration - _cutInfo.cutMaxDuration) {
        offset = _cutInfo.videoDuration - _cutInfo.cutMaxDuration - 0.00001;    // 防止大于视频长度导致出错
    }else if(offset < 0){
        offset = 0;
    }
    if (offset >= 0  && _cutInfo.videoDuration - offset >= _cutInfo.cutMaxDuration) {
        _cutInfo.offsetTime = offset;
        [self avplayerFromTime:_cutInfo.offsetTime + _cutInfo.startTime toTime:0 play:NO];
    }
    
    [self addThumbnail:nil];/* 缩略图没有加载完 */
}

@end
