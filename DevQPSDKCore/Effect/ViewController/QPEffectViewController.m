//
//  QPEffectViewController.m
//  QupaiSDK
//
//  Created by yly on 15/6/17.
//  Copyright (c) 2015年 lyle. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import "QupaiSDK.h"
#import "QupaiSDK-Private.h"
#import "QPEffectViewController.h"
#import "QPEffectViewCell.h"
#import "QPEffectLoadMoreCell.h"
#import "QPEffectManager.h"
#import "QPEffectTabView.h"
#import "QPEventManager.h"
#import <QPSDKCore/QPAuth-Private.h>
#import <QPSDKCore/QPVideoWatermarkGenerator.h>
#import "QPEffectView.h"


typedef enum {
    QPEffectTabFilter,
    QPEffectTabMV,
    QPEffectTabMusic,
} QPEffectTab;

NSString *QPMoreMusicUpdateNotification = @"kQPMoreMusicUpdateNotification";

@interface QPEffectViewController()<QPEffectViewDelegate,QPMediaRenderDelegate>

@property (nonatomic, assign) QPEffectTab selectTab;
@property (nonatomic, strong) QPEffectView *qpEffectView;
@property (nonatomic, strong) QPVideoWatermarkGenerator *generator;

@property (nonatomic, assign) QPMediaPackAudioMixType audioMixType;
@end

@implementation QPEffectViewController{
//    QPEffectManager *_effectManager;
    
    QPMediaRender *_mediaRender;//渲染的封装
    
    BOOL _shouldPlay;
    BOOL _shouldSave;
    BOOL _cancelMovie;
    
    BOOL _viewIsShow;
    BOOL _viewIsBackground;
    BOOL _usedBaseLine;
    
    BOOL _isSaving;
    
    BOOL _endingWatermarkEnabled;
    
    BOOL _GPUImageMovieWriterAppendBufferFailed;
    NSTimeInterval _startEncodingTime;
}

- (void)loadView {
    self.qpEffectView = [[QPEffectView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.qpEffectView.delegate = self;
    self.view = _qpEffectView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNotification];
    [self addObserver];
    
    if ([QPSDKConfig isBigBig]) {
        self.qpEffectView.constraintViewCenterTop.constant = 26;
        self.qpEffectView.constraintViewBottomTop.constant = 26;
    }
    
    if (!self.qpEffectView.gpuImageView) {
        CGRect renderFrame =  CGRectMake(0, 0, ScreenWidth,  ScreenWidth);
        UIView *renderView = [QPMediaRender createRenderViewWithFame:renderFrame];
        [self.qpEffectView.viewCenter addSubview:renderView];
        self.qpEffectView.gpuImageView = renderView;
    }
    
//    _effectManager = [QPEffectManager sharedManager];
    self.qpEffectView.collectionView.delegate = (id)self;
    self.qpEffectView.collectionView.dataSource = (id)self;
    [self.qpEffectView.collectionView registerNib:[UINib nibWithNibName:@"QPEffectViewCell" bundle:[QPBundle mainBundle]] forCellWithReuseIdentifier:@"QPEffectViewCell"];
    [self.qpEffectView.collectionView registerNib:[UINib nibWithNibName:@"QPEffectLoadMoreCell" bundle:[QPBundle mainBundle]] forCellWithReuseIdentifier:@"QPEffectLoadMoreCell"];
    
    [self.qpEffectView.sliderMix setMinimumTrackImage:[QPImage imageNamed:@"record_level"] forState:UIControlStateNormal];
    [self.qpEffectView.sliderMix setMaximumTrackImage:[QPImage imageNamed:@"edit_levelbase"] forState:UIControlStateNormal];
    self.qpEffectView.sliderMix.value = 1 - self.video.mixVolume;
    [self.qpEffectView.sliderMix setThumbImage:[QPImage imageNamed:@"record_handle"] forState:UIControlStateNormal];
    [self.qpEffectView.sliderMix setThumbImage:[QPImage imageNamed:@"record_handle"] forState:UIControlStateHighlighted];
    
    [self.qpEffectView.labelMixLeft setTextColor:[QupaiSDK shared].tintColor];
    
    if ([self.video.lastEffectName isEqual:@"music"]) {
        self.selectTab = QPEffectTabMusic;
        [self.qpEffectView.viewTab selectIndex:1 withAnimation:NO];
    }else{
        self.selectTab = QPEffectTabFilter;
        [self.qpEffectView.viewTab selectIndex:0 withAnimation:NO];
    }
    
    _endingWatermarkEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _viewIsShow = YES;
    [self.view layoutIfNeeded];
    _shouldPlay = YES;
    [self destroyMovie];
    
    // 关闭手势滑动返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _viewIsShow = NO;
}

- (void)dealloc {
    [self removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notiction

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GPUImageMovieWriterAppendBufferFailed:)
                                                 name:@"GPUImageMovieWriterAppendBufferFailed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillEnterForeground:) name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreMusicUpdateNotification:) name:QPMoreMusicUpdateNotification object:nil];
}

- (void)GPUImageMovieWriterAppendBufferFailed:(NSNotification *)notification {
    _GPUImageMovieWriterAppendBufferFailed = YES;
    [_mediaRender cancel];
}

- (void)_applicationWillEnterForeground:(NSNotification *)notification {
    _viewIsBackground = NO;
    if (self.qpEffectView.activityIndicator.isAnimating) {
        [self.qpEffectView.activityIndicator stopAnimating];
        self.qpEffectView.buttonFinish.hidden = NO;
        self.qpEffectView.buttonClose.enabled = YES;
        self.qpEffectView.viewBottom.userInteractionEnabled = YES;
    }
    if (!_mediaRender) {
        _shouldPlay = YES;
        [self destroyMovie];
    }
    
    if (_isSaving) {
        _isSaving = NO;
        _cancelMovie = NO;
        _mediaRender = nil;
        _shouldPlay = YES;
        [self destroyMovie];
    }
    
}

- (void)_applicationDidEnterBackground:(NSNotification *)notification {
    _viewIsBackground = YES;
    [self destroyMovie];
    sleep(1.0);
    NSLog(@"EffectViewController background");
}

- (void)moreMusicUpdateNotification:(NSNotification *)notification {
    [[QPEffectManager sharedManager] needUpdateMusicData];
    [self onClickButtonMusicAction:nil];
}
#pragma mark - KVO

- (NSArray *)allObserverKey {
    return @[@"selectTab",@"_video.mixVolume"];
}
- (void)addObserver {
    for (NSString *key in [self allObserverKey]) {
        [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectTab"]) {
        if (_selectTab == QPEffectTabFilter || _selectTab == QPEffectTabMV) {
            self.qpEffectView.viewMix.hidden = YES;
        }else{
            self.qpEffectView.viewMix.hidden = NO;
        }
        [self.qpEffectView.collectionView reloadData];
        
        NSInteger i = 0;
        if (_selectTab == QPEffectTabFilter) {
            i = [[QPEffectManager sharedManager] effectIndexByID:self.video.filterID type:QPEffectTypeFilter];
        }else if (_selectTab == QPEffectTabMV) {
            i = [[QPEffectManager sharedManager] effectIndexByID:self.video.mvID type:QPEffectTypeMV];
        }else{
            i = [[QPEffectManager sharedManager] effectIndexByID:self.video.musicID type:QPEffectTypeMusic];
        }
        [self selectItemAtIndex:i];
    }else if ([keyPath isEqual:@"_video.mixVolume"]){
        self.qpEffectView.sliderMix.value = 1.0 - self.video.mixVolume;
    }
}

- (void)removeObserver {
    for (NSString *key in [self allObserverKey]) {
        @try {
            [self removeObserver:self forKeyPath:key];
        } @catch (NSException *exception) {
        }
    }
}

#pragma mark - Collection

- (void)selectItemAtIndex:(NSInteger)index {
    NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
    [self.qpEffectView.collectionView selectItemAtIndexPath:ip animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self collectionView:self.qpEffectView.collectionView didSelectItemAtIndexPath:ip];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selectTab == QPEffectTabFilter) {
        return [[QPEffectManager sharedManager] effectCountByType:QPEffectTypeFilter];
    }else if (_selectTab == QPEffectTabMV) {
        return [[QPEffectManager sharedManager] effectCountByType:QPEffectTypeMV];
    }else {
        return [[QPEffectManager sharedManager] effectCountByType:QPEffectTypeMusic];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QPEffect *effect = nil;
    if (_selectTab == QPEffectTabFilter) {
        effect = [[QPEffectManager sharedManager] effectAtIndex:indexPath.row type:QPEffectTypeFilter];
    }else if (_selectTab == QPEffectTabMV){
        effect = [[QPEffectManager sharedManager] effectAtIndex:indexPath.row type:QPEffectTypeMV];
    }else{
        effect = [[QPEffectManager sharedManager] effectAtIndex:indexPath.row type:QPEffectTypeMusic];
    }
    
    QPEffectViewCell *cell = (QPEffectViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"QPEffectViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.nameLabel.text = effect.name;
    cell.iconImageView.image = [QPImage imageNamed:effect.icon];
    cell.contentView.frame = cell.bounds;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QPEffect *effect = nil;
    if (_selectTab == QPEffectTabFilter) {
        effect = [[QPEffectManager sharedManager] effectAtIndex:indexPath.row type:QPEffectTypeFilter];
        self.video.filterID = effect.eid;
        self.video.preferFilterOrMV = YES;
    }else if(_selectTab == QPEffectTabMV){
        effect = [[QPEffectManager sharedManager] effectAtIndex:indexPath.row type:QPEffectTypeMV];
        if ([effect isMore]) {
        }else if([effect isEmpty]){
            self.audioMixType = QPMediaPackAudioMixTypeOrigin;
            self.video.mvID = effect.eid;
            self.video.preferFilterOrMV = NO;
        }else {
            self.audioMixType = QPMediaPackAudioMixTypeMVMusic;
            self.video.mvID = effect.eid;
            self.video.preferFilterOrMV = NO;
            [self checkMVResourceExists];
        }
    }else{
        effect = [[QPEffectManager sharedManager] effectAtIndex:indexPath.row type:QPEffectTypeMusic];
        if ([effect isMore]) {
            if ([QupaiSDK.shared.delegte respondsToSelector:@selector(qupaiSDKShowMoreMusicView:viewController:)]) {
                _viewIsShow = NO;
                [self destroyMovie];
                [QupaiSDK.shared.delegte qupaiSDKShowMoreMusicView:(id<QupaiSDKDelegate>)QupaiSDK.shared viewController:self];
            }
        }else if([effect isEmpty]){
            self.video.mixVolume = 1.0;
            self.video.musicID = effect.eid;
            self.audioMixType = QPMediaPackAudioMixTypeOrigin;
        }else {
            self.video.mixVolume = 0.5;
            self.video.musicID = effect.eid;
            self.audioMixType = QPMediaPackAudioMixTypeMusic;
        }
    }
    
    if (![effect isMore]) {
        _shouldPlay = YES;
        [self destroyMovie];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 95);
}

#pragma mark - Play

- (void)playMovieAndAudio {
    _shouldPlay = NO;
    if (!_viewIsShow) {
        return;
    }
    [self playDirectorAtTime:0.0];
}

- (void)playDirectorAtTime:(CGFloat)atTime {
#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    QPMediaPack *pack = [self meidaPackByCurrentUserSetting];
    _mediaRender = [[QPMediaRender alloc] initWithMediaPack:pack];
    _mediaRender.delegate = self;
    [_mediaRender startRenderToView:self.qpEffectView.gpuImageView];
}

-(void)saveMovieToFile {
    _shouldSave = NO;
    
    if (_mediaRender) {
        return;
    }
    NSString *pathFile = [self.video newUniquePathWithExt:@"mp4"];
    CGSize size = self.video.size;
    
    NSString *profileLevel = AVVideoProfileLevelH264Baseline30;
    if (_GPUImageMovieWriterAppendBufferFailed) {
        _GPUImageMovieWriterAppendBufferFailed = NO;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            profileLevel = AVVideoProfileLevelH264BaselineAutoLevel;
        }
    }else{
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            profileLevel = AVVideoProfileLevelH264BaselineAutoLevel;
        }else{
            profileLevel = AVVideoProfileLevelH264Baseline30;
        }
    }

    QPMediaPack *pack = [self meidaPackByCurrentUserSetting];
    //save
    pack.saveWatermarkImage = [[QupaiSDK shared] watermarkImage];
    pack.savePath = pathFile;
    pack.saveProfileLevel = profileLevel;
    pack.saveSize = size;
    pack.saveBitRate = self.video.bitRate;
    
    _mediaRender = [[QPMediaRender alloc] initWithMediaPack:pack];
    _mediaRender.delegate = self;
    [_mediaRender startExport];
    _isSaving = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;

}

- (QPMediaPack *)meidaPackByCurrentUserSetting {
    QPEffectFilter *effectFilter = (QPEffectFilter *)[[QPEffectManager sharedManager] effectByID:self.video.filterID type:QPEffectTypeFilter];
    QPEffectMV *effectMV = (QPEffectMV *)[[QPEffectManager sharedManager] effectByID:self.video.mvID type:QPEffectTypeMV];
    QPEffectMusic *effectMusic = (QPEffectMusic *)[[QPEffectManager sharedManager] effectByID:self.video.musicID type:QPEffectTypeMusic];
    QPMediaPack *pack = [[QPMediaPack alloc] init];
    pack.videoPathArray = [self.video fullPathsForFilePathArray];
    pack.musicPath = effectMusic.musicName;
    pack.mixVolume = self.video.mixVolume;
    pack.videoSize = self.video.size;
    pack.audioMixType = self.audioMixType;
    pack.rotateArray = [self.video AllPointsRotate];
    if (self.video.preferFilterOrMV) {
        if (effectFilter.resourceLocalUrl) {
            pack.effectPath = effectFilter.resourceLocalUrl;
        }
    }else {
        if(effectMV.resourceLocalUrl) {
            pack.effectPath = [effectMV resourceLocalRatioPathWithRatio:[self mvRatioWithCurrentVideo]];
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:pack.effectPath];
            if (!exists) {
                pack.effectPath = nil;
            }
        }
    }
    return pack;
}
 
// 根据当前视频长宽比和是否旋转获取mv长宽比
- (QPEffectMVRatio)mvRatioWithCurrentVideo {
    QPVideoRatio videoAspect = [[QupaiSDK shared] videoRatio];
    QPVideoPoint *point = [self.video pointAtIndex:0];
    BOOL rotate = (point.rotate == 1|| point.rotate == 3);
    if (rotate) {
        if (videoAspect == QPVideoRatio9To16) {
            return QPEffectMVRatio16To9;
        }else if(videoAspect == QPVideoRatio16To9) {
            return QPEffectMVRatio9To16;
        }else if (videoAspect == QPVideoRatio4To3) {
            return QPEffectMVRatio3To4;
        }else if (videoAspect == QPVideoRatio3To4) {
            return QPEffectMVRatio4To3;
        }
    }
    return (QPEffectMVRatio)videoAspect;
}

- (void)checkMVResourceExists {
    QPEffectMV *effectMV = (QPEffectMV *)[[QPEffectManager sharedManager] effectByID:self.video.mvID type:QPEffectTypeMV];
    NSString *path = [effectMV resourceLocalRatioPathWithRatio:[self mvRatioWithCurrentVideo]];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!exists) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"^_^对不起，您所选择的MV不支持本视频" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - Direcot System

- (void)destroyMovie
{
    if (_cancelMovie) {
        return;
    }
    if (_mediaRender) {
        _cancelMovie = YES;
        
        [_mediaRender cancel];
        
    }else if(_shouldSave){
        
        [self saveMovieToFile];
        
    }else if (_shouldPlay) {
        [self playMovieAndAudio];
    }
}

- (void)effectVideoCompleteBlockCallback:(NSURL *)url
{
    if (self.qpEffectView.activityIndicator.isAnimating) {
        [self.qpEffectView.activityIndicator stopAnimating];
        self.qpEffectView.buttonFinish.hidden = NO;
        self.qpEffectView.buttonClose.enabled = YES;
        self.qpEffectView.viewBottom.userInteractionEnabled = YES;
    }
    // 销毁writer
    //    [self destroyWriter];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    NSURL *thumbnailURL = [QPVideo movieFirstFrame:url toPath:[self.video newUniquePathWithExt:@"jpg"]
                                           quality:QupaiSDK.shared.thumbnailCompressionQuality];
    
    [[QupaiSDK shared] compelete:url.path thumbnailPath:thumbnailURL.path];
}

#pragma mark - Delegate

- (void)currentVideoCompositionWithPlan:(CGFloat)plan {
    if (plan >= 1.0) {
        plan = 1.0;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.qpEffectView.activityIndicator isAnimating]) {
            NSLog(@"%@", [NSString stringWithFormat:@"%3.f%%", plan * 100]);
        }
    });
}

- (void)mediaRenderCancel:(QPMediaRender *)render;
{
    if (![render isPlayMode]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_viewIsBackground) {// 如果进入后台，取消保存操作
                [self destroyMovie];
            }else{
                [_mediaRender finishRecordingWithCompletionHandler:^(NSURL *url){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_GPUImageMovieWriterAppendBufferFailed) {
                            _shouldSave = YES;
                            [self destroyMovie];
                        }else{
                            [self processVideoLength:url];
                        }
                    });
                }];
            }
        });
        return;
    }
    
    BOOL showPlay = [render isPlayMode];
    if (_viewIsBackground || !_viewIsShow) {
        showPlay = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_mediaRender) {
            _mediaRender = nil;
        }
        _shouldPlay = showPlay;
        _cancelMovie = NO;
        
        [self destroyMovie];
    });
}

- (void)directorPlayTime:(CGFloat)time format:(NSString *)format {

}

- (void)processVideoLength:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetTrack *videoTrack;
    AVAssetTrack *audioTrack;
    
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    if (videoTrack && audioTrack) {
        float videoDuration = CMTimeGetSeconds(videoTrack.timeRange.duration);
        float audioDuration = CMTimeGetSeconds(audioTrack.timeRange.duration);
        if (audioDuration - videoDuration > 0.5 && !_usedBaseLine) {
            _GPUImageMovieWriterAppendBufferFailed = YES;
            _usedBaseLine = YES;
            _shouldSave = YES;
            [self destroyMovie];
            
            return;///返回
        }
    }
    if (url) {
        NSLog(@"completeHandler start");
        void(^completeHandler)(NSURL *url, NSError *error)  = ^(NSURL *url, NSError *error){
            NSTimeInterval finishEncodingTime = [[NSDate date] timeIntervalSince1970];
            CGFloat encodingDuration = finishEncodingTime - _startEncodingTime;
            [[QPEventManager shared] event:QPEventEncodeFinish
                                withParams:@{@"duration":[NSNumber numberWithInt:encodingDuration * 1000],
                                             @"filter":self.video.filterID ? @(1) : @(0),
                                             @"music":self.video.musicID ? @(1) : @(0)}];
            [self effectVideoCompleteBlockCallback:url];
        };
        if (_endingWatermarkEnabled) {
            [self videoByAppendEndingWatermark:url completeHandler:^(NSURL *url, NSError *error) {
                completeHandler(url, error);
            }];
        }else {
            completeHandler(url, nil);
        }
    }
}

- (void)videoByAppendEndingWatermark:(NSURL *)url completeHandler:(void(^)(NSURL *url, NSError *error))handler {
    QPVideoCombine *combiner = [[QPVideoCombine alloc] initWithOutputSize:self.video.size];
    AVURLAsset *sourceAsset = [AVURLAsset assetWithURL:url];
    [combiner addAsset:sourceAsset rotate:0 withError:nil];
    self.generator = [[QPVideoWatermarkGenerator alloc] init];
    self.generator.watermarkImage = [UIImage imageNamed:@"watermark"];
    self.generator.watermarkSize = CGSizeMake(270, 117);
    self.generator.bitRate = self.video.bitRate;
    self.generator.bgImage = [self lastFrameOfAsset:sourceAsset];
    NSString *videoWatermarkPath = [self.video newUniquePathWithExt:@"mp4"];
    self.generator.outputUrl = [NSURL fileURLWithPath:videoWatermarkPath];
    NSLog(@"ending watermark start");
    [self.generator generateWithCompleteHandler:^(NSError *error, NSURL *url) {
        NSLog(@"ending watermark finish");
        [combiner addAsset:[AVURLAsset assetWithURL:url] rotate:0 withError:nil];
        NSString *outputPath = [self.video newUniquePathWithExt:@"mp4"];
        NSURL *outputUrl = [NSURL fileURLWithPath:outputPath];
        [combiner exportTo:outputUrl withPreset:AVAssetExportPresetPassthrough withCompletionHandler:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(outputUrl, error);
                self.generator = nil;
            });
        }];
    }];
}

- (UIImage *)lastFrameOfAsset:(AVURLAsset *)asset {
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    CGImageRef imageRef = [generator copyCGImageAtTime:videoTrack.timeRange.duration actualTime:nil error:nil];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

#pragma mark - Action

- (void)onClickButtonCloseAction:(UIButton *)sender {
    _viewIsShow = NO;
    [self destroyMovie];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickButtonFinishAction:(UIButton *)sender {
    [self.qpEffectView.activityIndicator startAnimating];
    self.qpEffectView.buttonFinish.hidden = YES;
    self.qpEffectView.buttonClose.enabled = NO;
    self.qpEffectView.viewBottom.userInteractionEnabled = NO;
    
    _shouldSave = YES;
    [self destroyMovie];
    [[QPEventManager shared] event:QPEventEditNext];
    _startEncodingTime = [[NSDate date] timeIntervalSince1970];
}

- (void)onCLickButtonPlayOrPauseAction:(UIButton *)sender {
    [_mediaRender playOrPause];
    if (!_mediaRender) {
        _shouldPlay = YES;
        [self destroyMovie];
    }
}

- (void)onClickButtonFilterAction:(UIButton *)sender {
    self.video.lastEffectName = @"filter";
    self.selectTab = QPEffectTabFilter;
}

- (void)onClickButtonMusicAction:(UIButton *)sender {
    self.video.lastEffectName = @"music";
    self.selectTab = QPEffectTabMusic;
}

- (void)onClickButtonMVAction:(UIButton *)sender {
    self.video.lastEffectName = @"mv";
    self.selectTab = QPEffectTabMV;
}

- (void)onClickSliderAction:(UISlider *)sender {
    self.video.mixVolume = 1.0 - self.qpEffectView.sliderMix.value;
    _shouldPlay = YES;
    [self destroyMovie];
}


@end
