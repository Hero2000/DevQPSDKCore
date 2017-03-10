//
//  QPRecordViewController.m
//  QupaiSDK
//
//  Created by yly on 15/6/16.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "QPRecordViewController.h"
#import "QPFocusView.h"
#import "QPEffectViewController.h"
#import "QPPickerPreviewViewController.h"
#import "QPRecordGuideView.h"
#import "QupaiSDK.h"
//#import "QPAuth-Private.h"
#import "QPRecordTipGuideView.h"
#import "QPCountDownView.h"
#import "QPEventManager.h"
#import "QPNavigationController.h"
#import "QPRecordView.h"
#import "QPPointProgress.h"

typedef NS_ENUM(NSInteger, QPRecordStatus) {
    QPRecordStatusEmpty,
    QPRecordStatusRecording,
    QPRecordStatusPause,
    QPRecordStatusTrash,
    QPRecordStatusCombine,
    QPRecordStatusReset
};

typedef NS_ENUM(NSInteger, QPRecordViewTag) {
    QPRecordViewTagDraftAlert = 100,
    QPRecordViewTagAuthAlert = 101
};


@interface QPRecordViewController()<QPRecordViewDelegate,QPRecordDelegate>

@property (nonatomic, assign) QPRecordStatus recordStatus;
@property (nonatomic, assign) BOOL countDown;
@property (nonatomic, strong) QPRecord *recorder;

@property (nonatomic, strong) QPRecordView *qpRecordView;

@end

@implementation QPRecordViewController{
    QPFocusView *_focusView;
    UIActionSheet *_actionSheet;
    
    NSInteger _deviceAngle;
    CGFloat _lastPinchDistance;
    CGFloat _lastPanY;
    
    struct {
        AVCaptureDevicePosition position;
        BOOL skin;
        BOOL manualSkin;
        BOOL isCountDown;
    } _recordFlag;
    
    __weak QPCountDownView *_countDownView;
    
    QPRecordGuideView *_guideView;
    QPRecordTipGuideView *_tipGuideView;
    CMMotionManager *_motionManager;
    
    // 美颜图标相关
    NSArray *_makeupIcoFrames;
    NSArray *_makeupImageFrames;
    UIImageView *_makeupAnimatedImage;

    BOOL _recordFinished; // 拍摄时间完成，从效果页面返回当前页的标志
    NSTimeInterval _startEncodingTime;
}

#pragma mark - life cycle

- (void)loadView {
    self.qpRecordView = [[QPRecordView alloc] initWithFrame:[UIScreen mainScreen].bounds videoSize:self.video.size bottomPanelHeight:[QupaiSDK shared].bottomPanelHeight];
    self.qpRecordView.delegate = self;
    self.view = self.qpRecordView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupSubviews];
    [self adaptiveUI];
    [self addObserver];
    [self addNotification];
    [self setupRecorder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view setNeedsLayout];
    
    self.qpRecordView.viewMask.hidden = NO;
    self.qpRecordView.viewCenter.userInteractionEnabled = NO;
    self.qpRecordView.viewBottom.userInteractionEnabled = NO;
    
    if (!QPSave.shared.recordGuide) {
        QPSave.shared.recordGuide = YES;
        _guideView = [[QPRecordGuideView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - [QupaiSDK shared].bottomPanelHeight)];
        _guideView.userInteractionEnabled = NO;
        [self.qpRecordView addSubview:_guideView];
    }
    [self chheckAddTipGuide];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_recordStatus == QPRecordStatusCombine) {
        if (self.video.duration >= self.video.maxDuration) {
            _recordFinished = YES;
        }else{
            [self.video letVideoDurationLessMaxDuration];
        }
        self.recordStatus = QPRecordStatusReset;
        self.recordStatus = QPRecordStatusPause;
    }
    [self startMotion];
    [self startToPreview];
    [self checkDraft];
//    [self checkAuth];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self endMotion];
    [self.recorder stopPreview];
}

-(void)viewWillLayoutSubviews{
    self.recorder.previewLayer.frame = self.qpRecordView.gpuImageView.bounds;
}

- (void)dealloc{
    [self removeObserver];
}

#pragma mark - Setup

- (void)setupSubviews {
    
    [self.navigationController.navigationBar setHidden:YES];
    _recordFlag.skin = NO;
    _recordFlag.manualSkin = NO;
    _recordFlag.isCountDown = NO;
    if ( [QupaiSDK shared].cameraPosition == QupaiSDKCameraPositionBack) {
        _recordFlag.position = AVCaptureDevicePositionBack;
    }else{
        _recordFlag.position = AVCaptureDevicePositionFront;
        if ([QupaiSDK shared].enableBeauty) {
            _recordFlag.skin = YES;
            self.qpRecordView.buttonSkin.selected = YES;
        }
    }
    self.countDown = NO;
    
    self.qpRecordView.pointProgress.colorNomal  = [QupaiSDK shared].tintColor;
    self.qpRecordView.pointProgress.colorBg     = RGBToColor(0,0,0, 0.1);
    self.qpRecordView.pointProgress.colorSelect = RGBToColor(255,72,72,1);
    self.qpRecordView.pointProgress.colorNotice = RGBToColor(255,255,255,1);
    self.qpRecordView.pointProgress.video = self.video;
    self.qpRecordView.pointProgress.hidden = YES;
    [self.view bringSubviewToFront:self.qpRecordView.pointProgress];
    
    [self.qpRecordView.sliderSkin setMinimumTrackImage:[QPImage imageNamed:@"record_level"] forState:UIControlStateNormal];
    [self.qpRecordView.sliderSkin setMaximumTrackImage:[QPImage imageNamed:@"record_levelbase"] forState:UIControlStateNormal];
    
    [self.qpRecordView.sliderSkin addTarget:self action:@selector(skinSliderValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    [self.qpRecordView.sliderSkin addTarget:self action:@selector(skinSliderTouchDown:) forControlEvents:(UIControlEventTouchDown)];
    [self.qpRecordView.sliderSkin addTarget:self action:@selector(skinSliderTouchCancel:) forControlEvents:(UIControlEventTouchUpOutside | UIControlEventTouchUpInside)];
    
    [self.qpRecordView.sliderSkin setThumbImage:[QPImage imageNamed:@"record_handle"] forState:UIControlStateNormal];
    [self.qpRecordView.sliderSkin setThumbImage:[QPImage imageNamed:@"record_handle"] forState:UIControlStateHighlighted];
    // 美颜图标
    [self setupMakeupFrames];
    [self.qpRecordView.skinBgImage setImage:[UIImage animatedImageWithImages:_makeupIcoFrames duration:2]];
    
    _focusView = [[QPFocusView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    _focusView.alpha = 0;
    _focusView.userInteractionEnabled = NO;
    [self.qpRecordView.viewFocusContent addSubview:_focusView];
    
}

-(void)setupMakeupFrames{
    NSMutableArray *makeupIcos = [[NSMutableArray alloc]initWithCapacity:26];
    NSMutableArray *makeupImages = [[NSMutableArray alloc]initWithCapacity:29];
    for (int i = 0; i < 29; i++) {
        NSString *imageFrame = [NSString stringWithFormat:@"makeup_img_frame_%05d.png",i];
        if (i < 26) {
            NSString *icoFrame = [NSString stringWithFormat:@"ico_mackup_%05d.png",i];
            [makeupIcos addObject:[QPImage imageNamed:icoFrame]];
            [makeupImages addObject:[QPImage imageNamed:imageFrame]];
        } else {
            [makeupImages addObject:[QPImage imageNamed:imageFrame]];
        }
    }
    _makeupIcoFrames = [NSArray arrayWithArray:makeupIcos];
    _makeupImageFrames = [NSArray arrayWithArray:makeupImages];
}

- (void)setupRecorder {
    self.recordStatus = QPRecordStatusEmpty;
    self.recorder = [[QPRecord alloc] init];
    [self.qpRecordView.gpuImageView.layer addSublayer:self.recorder.previewLayer];
    [self.recorder setDelegate:self];
}

#pragma mark - Draft

- (void)checkDraft{
    if (_videoIsDraft) {
        _videoIsDraft = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"上次视频编辑未完成,是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        alertView.tag = QPRecordViewTagDraftAlert;
        [alertView show];
    }
}

#pragma mark - Preview

- (void)setRecordStatus:(QPRecordStatus)recordStatus{
    if (_recordStatus == QPRecordStatusCombine && recordStatus != QPRecordStatusReset) {
        return;
    }
    if (_recordStatus == recordStatus) {
        return;
    }
    [self willChangeValueForKey:@"recordStatus"];
    _recordStatus = recordStatus;
    [self didChangeValueForKey:@"recordStatus"];
}

/*开始录音*/
- (void)startToPreview{
    [self cameraCanRecord:^(BOOL granted) {
        if (granted) {
            [self audioCanRecord:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        [self.recorder startPreviewWithVideoSize:self.video.size position:_recordFlag.position skin:_recordFlag.skin];
                    });
                    return ;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        NSString *msg = [NSString stringWithFormat:@"无法使用拍摄功能，请在手机的设置>隐私>麦克风中开启%@的访问权限",
                                         [[QupaiSDK shared] appName]];
                        [[[UIAlertView alloc] initWithTitle:@""
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil] show];
                        return;
                    }
                });
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *msg = [NSString stringWithFormat:@"无法使用拍摄功能，请在手机的设置>隐私>相机中开启%@的访问权限",
                                 [[QupaiSDK shared] appName]];
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:msg
                                           delegate:self
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil] show];
                return;
            });
        }
    }];
}

- (void)audioCanRecord:(void (^)(BOOL granted))handler{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending){
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:handler];
        }else if(status == AVAuthorizationStatusRestricted){
            if (handler) { handler(NO); }
        }else if(status == AVAuthorizationStatusDenied){
            if (handler) { handler(NO); }
        }else if(status == AVAuthorizationStatusAuthorized){
            if (handler) { handler(YES); }
        }
    }else{
        if (handler) { handler(YES); }
    }
}

- (void)cameraCanRecord:(void (^)(BOOL granted))handler{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending){
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:handler];
        }else if(status == AVAuthorizationStatusRestricted){
            if (handler) { handler(NO); }
        }else if(status == AVAuthorizationStatusDenied){
            if (handler) { handler(NO); }
        }else if(status == AVAuthorizationStatusAuthorized){
            if (handler) { handler(YES); }
        }
    }else{
        if (handler) { handler(YES); }
    }
}

#pragma mark - Notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumnHandler:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationResignActive:) name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)volumnHandler:(NSNotification *)sender {
    NSString *changeType = [[sender userInfo] objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    if ([changeType isEqualToString:@"ExplicitVolumeChange"]) {
        [self onCLickButtonTimeAction:nil];
    }
}

- (void)applicationResignActive:(NSNotification *)notification
{
    [self onClickButtonRecordUpAction:nil];
}

#pragma mark - KVO

- (NSArray *)allObserverKey {
    return @[@"_video.duration", @"recordStatus", @"countDown"];
}
- (void)addObserver {
    for (NSString *key in [self allObserverKey]) {
        [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"_video.duration"]) {
        [self updateUIRecordDurationChange];
    }
    if ([keyPath isEqualToString:@"recordStatus"]) {
        [self updateRecordStatus];
        // 拍摄和合成阶段防止锁屏
        if (_recordStatus == QPRecordStatusCombine || _recordStatus == QPRecordStatusRecording) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        }else{
            [UIApplication sharedApplication].idleTimerDisabled = NO;
        }
    }
    if ([keyPath isEqualToString:@"countDown"]) {
        [self changeUIWithEnableTime:_countDown];
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

#pragma mark - UI

- (void)changeButton:(UIButton *)button image:(NSString *)name size:(CGSize)size x:(CGFloat)x {
    UIImage *image = [QPImage imageNamed:name];
    [self.qpRecordView.buttonLibrary setImage:image forState:UIControlStateNormal];
    
    CGPoint p = button.center;
    button.frame = CGRectMake(0, 0, size.width, size.height);
    button.center = p;
    
    CGRect f = button.frame;
    f.origin.x = x;
    button.frame = f;
}

- (void)updateRecordStatus {
    if (_recordStatus == QPRecordStatusEmpty) {
        if (QupaiSDK.shared.enableImport) {
            [self changeButton:self.qpRecordView.buttonLibrary image:@"record_ico_input" size:CGSizeMake(55, 55) x:34];
        }else{
            [self changeButton:self.qpRecordView.buttonLibrary image:nil size:CGSizeMake(55, 55) x:34];
        }
        self.qpRecordView.pointProgress.showCursor = YES;
        self.qpRecordView.pointProgress.showBlink = YES;
        [_tipGuideView removeAllGuideView];
    }else if (_recordStatus == QPRecordStatusPause) {
        [self changeButton:self.qpRecordView.buttonLibrary image:@"record_ico_delete" size:CGSizeMake(55, 55) x:20];
        
        self.video.lastSelected = NO;
        
        self.qpRecordView.pointProgress.showCursor = YES;
        self.qpRecordView.pointProgress.showBlink = YES;
        
        self.qpRecordView.buttonRecord.highlighted = NO;
        self.qpRecordView.viewSkin.hidden = !self.recorder.skinFilterEnabled;
        
        self.qpRecordView.buttonFinish.enabled = YES;
        self.qpRecordView.buttonRecord.enabled = YES;
        self.qpRecordView.buttonLibrary.enabled = YES;
        self.qpRecordView.buttonSkin.enabled = YES;
        
        // ADD
        self.qpRecordView.buttonTime.selected = NO;
        self.qpRecordView.buttonClose.enabled = YES;
        self.qpRecordView.buttonPosition.enabled = YES;
        self.qpRecordView.buttonTime.enabled = YES;
        
        self.qpRecordView.viewCenter.userInteractionEnabled = YES;
        self.qpRecordView.viewBottom.userInteractionEnabled = YES;
        
        [self.qpRecordView.activityIndicator stopAnimating];
        [_guideView recordPause];
        
        if (!QPSave.shared.backDeleteTipGuide && self.video.pointCount == 2) {
            QPSave.shared.backDeleteTipGuide = YES;
            [_tipGuideView removeAllGuideView];
            [_tipGuideView addDeleteGuideInPoint:[self.view convertRect:self.qpRecordView.buttonLibrary.frame fromView:self.qpRecordView.viewBottom]];
        }
    }else if (_recordStatus == QPRecordStatusTrash) {
        [self changeButton:self.qpRecordView.buttonLibrary image:@"record_ico_delete_1" size:CGSizeMake(55, 55) x:20];
        
        self.qpRecordView.pointProgress.showBlink = NO;
        self.qpRecordView.pointProgress.showCursor = NO;
        
        self.video.lastSelected = YES;
        
        if (!QPSave.shared.backDeleteTrashTipGuide) {
            QPSave.shared.backDeleteTrashTipGuide = YES;
            [_tipGuideView removeAllGuideView];
            [_tipGuideView addDeleteTrashGuideInPoint:[self.view convertRect:self.qpRecordView.buttonLibrary.frame fromView:self.qpRecordView.viewBottom]];
        }
    }else if (_recordStatus == QPRecordStatusRecording) {
        self.video.lastSelected = NO;
        
        self.qpRecordView.buttonRecord.highlighted = YES;
        self.qpRecordView.viewSkin.hidden = YES;
        
        // add
        self.qpRecordView.buttonLibrary.enabled = NO;
        self.qpRecordView.buttonClose.enabled = NO;
        self.qpRecordView.buttonFinish.enabled = NO;
        self.qpRecordView.buttonPosition.enabled = NO;
        
        self.qpRecordView.buttonTime.enabled = _countDown;
        
        
        self.qpRecordView.pointProgress.showBlink = NO;
        self.qpRecordView.pointProgress.showCursor = YES;
        
        [_guideView recordDoing];
        [_tipGuideView removeAllGuideView];
    }else if (_recordStatus == QPRecordStatusCombine) {
        self.qpRecordView.buttonFinish.enabled = NO;
        self.qpRecordView.buttonRecord.enabled = NO;
        self.qpRecordView.buttonLibrary.enabled = NO;
        self.qpRecordView.buttonSkin.enabled = NO;
        self.qpRecordView.buttonPosition.enabled = NO;
        self.qpRecordView.buttonTime.enabled = NO;
        self.qpRecordView.viewCenter.userInteractionEnabled = NO;
        self.qpRecordView.viewBottom.userInteractionEnabled = NO;
        
        [self.qpRecordView.activityIndicator startAnimating];
        [_guideView recordFinish];
        [_tipGuideView removeAllGuideView];
        [_guideView removeFromSuperview];
    }
    [self updateUIRecordDurationChange];
}

- (void)updateUIRecordDurationChange {
    [self.qpRecordView.pointProgress updateProgress:0];
    
    self.qpRecordView.buttonFinish.enabled = self.video.duration >= self.video.minDuration;
    self.qpRecordView.buttonRecord.enabled = self.video.duration < self.video.maxDuration;
    self.qpRecordView.pointProgress.showNoticePoint = self.video.duration < self.video.minDuration;
    
    if (self.video.duration >= self.video.maxDuration && _recordStatus!= QPRecordStatusCombine) {
        
        if (_recordFinished) {
             self.qpRecordView.buttonRecord.enabled = NO;
            self.qpRecordView.buttonTime.enabled = NO;
        }else{
            self.recordStatus = QPRecordStatusCombine;
            [self.recorder finishRecording];
            [[QPEventManager shared] event:QPEventRecordAutonext];
        }
        
    }
    if ((_recordStatus == QPRecordStatusPause || _recordStatus == QPRecordStatusTrash) && [self.video isEmpty]) {
        self.recordStatus = QPRecordStatusEmpty;
    }
    if (_recordStatus == QPRecordStatusEmpty && ![self.video isEmpty]) {
        self.recordStatus = QPRecordStatusPause;
    }
    if (_recordStatus == QPRecordStatusTrash && self.video.lastSelected == NO) {
        self.recordStatus = QPRecordStatusPause;
    }
    if (_recordStatus == QPRecordStatusCombine) {
        
    }
    if (_recordStatus == QPRecordStatusReset) {
    }
}

- (void)adaptiveUI {
    if ([QPSDKConfig is35]) {
        [self.qpRecordView.pointProgress.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = 4;
                *stop = YES;
            }
        }];
    }
    
    if (![QupaiSDK shared].enableBeauty) {
        self.qpRecordView.buttonSkin.hidden = YES;
        self.qpRecordView.skinBgImage.hidden = YES;
//        _makeupAnimatedImage.hidden = YES;
    }
}

#pragma mark - Motion

- (void)startMotion {
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.5;
    }
    if (_motionManager.accelerometerActive) {
        return;
    }
    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:
     ^(CMAccelerometerData *accelerometerData, NSError *error) {
         if ([self.recorder isRecording]) {
             return;
         }
         CMAcceleration acceleration = accelerometerData.acceleration;
         float xx = -acceleration.x;
         float yy = acceleration.y;
         float angle = atan2(yy, xx);
         float z = acceleration.z;
         
         if (z <= -0.8 || z >= 0.8) {
             return;
         }
         NSString *ori = @"";
         NSInteger oldAngle = _deviceAngle;
         if(angle >= -2 && angle <= -1){
             ori = @"Up";
             _deviceAngle = 0;
         }else if(angle >= -0.5 && angle <= 0.5){
             ori = @"Right";
             _deviceAngle = 90;
         }else if(angle >= 1 && angle <= 2){
             ori = @"Down";
             _deviceAngle = 180;
         }else if(angle <= -2.5 || angle >= 2.5){
             ori = @"Left";
             _deviceAngle = 270;
         }
         
         if (oldAngle != _deviceAngle) {
             CGPoint centerPoint = [self.qpRecordView.viewFocusContent convertPoint:_focusView.center toView:self.qpRecordView.viewCenter];
             self.qpRecordView.viewFocusContent.transform = CGAffineTransformMakeRotation(M_PI/180 * _deviceAngle);
             CGPoint np = centerPoint;
             if (_deviceAngle == 90) {
                 np = CGPointMake(np.y, ScreenWidth - np.x);
             }else if(_deviceAngle == 180){
                 np = CGPointMake(ScreenWidth - np.x, ScreenWidth - np.y);
             }else if(_deviceAngle == 270){
                 np = CGPointMake(ScreenWidth - np.y, np.x);
             }
             _focusView.center = np;
             [_focusView refreshPosition];
         }
         
         [UIView animateWithDuration:0.3 animations:^{
             CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/180.0 * _deviceAngle);
             self.qpRecordView.buttonClose.transform = transform;
             self.qpRecordView.buttonPosition.transform = transform;
             self.qpRecordView.buttonSkin.transform = transform;
             self.qpRecordView.buttonTime.transform = transform;
             self.qpRecordView.buttonLibrary.transform = transform;
             self.qpRecordView.buttonFinish.transform = transform;
         }];
     }];
}

- (void)endMotion {
    if (_motionManager) {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = nil;
    }
}

#pragma mark - Guide
- (void)chheckAddTipGuide {
    _tipGuideView = [[QPRecordTipGuideView alloc] initWithFrame:self.view.bounds];
    if (!QPSave.shared.skinTipGuide) {
        QPSave.shared.skinTipGuide = YES;
        [_tipGuideView addSkinGuideInPoint:self.qpRecordView.buttonSkin.frame];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_tipGuideView removeAllGuideView];
        });
    }
    if (!QPSave.shared.recordImportTipGuide && QupaiSDK.shared.enableImport) {
        QPSave.shared.recordImportTipGuide = YES;
        [_tipGuideView addImportGuideInPoint:[self.view convertRect:self.qpRecordView.buttonLibrary.frame fromView:self.qpRecordView.viewBottom]];
    }
    [self.view addSubview:_tipGuideView];
}

#pragma mark - QPCountDownView Delegate

- (BOOL)countDownView:(QPCountDownView *)countDownView showCount:(NSInteger)showCount {
    if (showCount > 1) {
        return YES;
    }
    [self removeCountView];
    self.qpRecordView.buttonRecord.enabled = YES;
    [self onClickButtonRecordDownAction:nil];
    return NO;
}

- (void)countDownViewAnimationFailed:(QPCountDownView *)countDownView {
    if(_countDown){
        self.countDown = NO;
    }
}

- (void)removeCountView {
    if (_countDownView) {
        [_countDownView endAnimation];
        [_countDownView removeFromSuperview];
        _countDownView = nil;
    }else{
        [self countDownViewAnimationFailed:nil];
    }
}

- (void)changeUIWithEnableTime:(BOOL)enableTime {
    if (enableTime) {
        [QPSave shared].countDownRecordTimes = [QPSave shared].countDownRecordTimes + 1;
    }
    CGFloat delay = 3.0;
    self.qpRecordView.buttonTime.selected = enableTime;
    self.qpRecordView.viewTimeNotice.hidden = !enableTime;
    self.qpRecordView.viewTimeNoticeTop.hidden = !enableTime;
    self.qpRecordView.viewTimeNoticeBottom.hidden = !enableTime;
    if ([QPSave shared].countDownRecordTimes > 3) {
        self.qpRecordView.viewTimeNoticeBottom.hidden = YES;
        delay = 1.0;
    }
    self.qpRecordView.buttonClose.enabled = !enableTime;
    
    self.qpRecordView.buttonLibrary.enabled = !enableTime;
    
    _guideView.hidden = _countDown;
    
    if (enableTime) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.qpRecordView.viewTimeNotice.hidden = YES;
            if (!_countDownView && _countDown) {
                QPCountDownView *countDownView = [[QPCountDownView alloc] initWithFrame:self.qpRecordView.viewCenter.bounds count:5];
                countDownView.delegate = (id<QPCountDownViewDelegate>)self;
                [self.qpRecordView.viewCenter addSubview:countDownView];
                _countDownView = countDownView;
                [countDownView startAnimation];
            }
        });
    }else{
        [self removeCountView];
        if (_recordFlag.isCountDown) {//如果录制，测取消，如果是主动取消倒计时录制，则不取消
//            [self buttonRecordUp:nil];
            [self onClickButtonRecordUpAction:nil];
        }
    }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"%@",title);
    
    if ([title isEqualToString:@"重新录制"]) {
        [self.video removeAllPoint];
        _recordFinished = NO;
        [[QPEventManager shared] event:QPEventRecordRetake];
    }else if([title isEqualToString:@"放弃录制"]){
        [[QupaiSDK shared] compelete:nil thumbnailPath:nil];
        [[QPEventManager shared] event:QPEventRecordAbandon];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == QPRecordViewTagDraftAlert) {
        if ([alertView cancelButtonIndex] == buttonIndex) {
            [self.video removeAllPoint];
        }else if (alertView.tag == QPRecordViewTagAuthAlert){
            // do nothing
        }else{
            if (_videoNeedToEffectView) {
                _videoNeedToEffectView = NO;
                QPEffectViewController *controller = [[QPEffectViewController alloc]
                                                      initWithNibName:@"QPEffectViewController" bundle:nil video:self.video];
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    }else if([alertView cancelButtonIndex] == buttonIndex) {
        [[QupaiSDK shared] compelete:nil thumbnailPath:nil];
    }
}
#pragma mark - Action

- (void)onClickButtonCloseAction:(UIButton *)sender {
    if (![self.video isEmpty]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self
                                                        cancelButtonTitle:@"取消" destructiveButtonTitle:@"放弃录制"
                                                        otherButtonTitles:@"重新录制", nil];
        [actionSheet showInView:self.view];
    }else{
        [[QupaiSDK shared] compelete:nil thumbnailPath:nil];
        [[QPEventManager shared] event:QPEventRecordQuit];
    }
}

-(void)onClickButtonPositionAction:(UIButton *)sender {
    AVCaptureDevicePosition position = [self.recorder switchCameraPosition];
    if (position == AVCaptureDevicePositionBack) {
        if (!_recordFlag.manualSkin && [self.recorder skinFilterEnabled]){
//            [self buttonSkinClick:nil];
            [self onClickButtonSkinAction:nil];
        }
    }else{
        if (![self.recorder skinFilterEnabled] && [QupaiSDK shared].enableBeauty) {
//            [self buttonSkinClick:nil];
            [self onClickButtonSkinAction:nil];
        }
    }
}

- (void)onCLickButtonTimeAction:(UIButton *)sender {
    
    self.countDown = !_countDown;
}

- (void)onClickButtonLibraryAction:(UIButton *)sender {
    
    [_tipGuideView removeAllGuideView];
    
    if ([self.video pointCount] > 0) {
        if (_recordStatus == QPRecordStatusPause) {
            self.recordStatus = QPRecordStatusTrash;
        }else if(_recordStatus == QPRecordStatusTrash){
            [self.video removeLastPoint];
            self.recordStatus = QPRecordStatusPause;
            [_guideView jumpToTime:self.video.duration];
            _recordFinished = NO;
            [[QPEventManager shared] event:QPEventRecordDeleteConfirm];
        }
    }else{
        if (!QupaiSDK.shared.enableImport) {
            return;
        }
        [self.recorder stopPreview];//提前停止preview，如果不，会租塞主线程
        
        QPPickerPreviewViewController *picker = [[QPPickerPreviewViewController alloc]
                                                 initWithNibName:@"QPPickerPreviewViewController" bundle:[QPBundle mainBundle]];
        picker.delegate = self;
        QPNavigationController *navigation = [[QPNavigationController alloc] initWithRootViewController:picker];
        [self presentViewController:navigation animated:YES completion:nil];
        [[QPEventManager shared] event:QPEventImportVideo];
    }
}

- (void)onClickButtonSkinAction:(UIButton *)sender {
    BOOL skin = !self.qpRecordView.buttonSkin.selected;
    self.qpRecordView.buttonSkin.selected = skin;
    self.qpRecordView.viewSkin.hidden = !skin;
    [self.recorder setSkinFilterEnabled:skin];
    _recordFlag.manualSkin = sender && skin;
    if (skin) {
        if (!QPSave.shared.skinOpenGuide) {
            QPSave.shared.skinOpenGuide = YES;
            [[QPProgressHUD sharedInstance] showtitleNotic:@"已开启美颜功能"];
        }
        [self displayMakeupAnimatedImage];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeMakeupAnimatedImage) userInfo:nil repeats:NO];
    }else{
        if (!QPSave.shared.skinCloseGuide) {
            QPSave.shared.skinCloseGuide = YES;
            [[QPProgressHUD sharedInstance] showtitleNotic:@"已关闭美颜功能"];
        }
    }
    if (skin) {
        self.qpRecordView.constraintViewSkinVerticalSpace.constant = _guideView ? 50 : 11;
    }
    [_tipGuideView removeAllGuideView];

}

- (void)onClickButtonRecordDownAction:(UIButton *)sender {
    
    if (sender && _countDown) {//取消定时拍摄
        self.countDown = NO;
        return;
    }
    if (self.video.duration >= self.video.maxDuration) {
        return;
    }
    
    _recordFlag.isCountDown = sender ? NO : YES;
    
    self.qpRecordView.buttonTime.enabled = _countDown;
    
    self.recordStatus = QPRecordStatusRecording;
    
    [self.recorder startRecording];
    
    
    BOOL front, beauty, countDown = NO;
    if([self.recorder captureDevicePosition] == AVCaptureDevicePositionFront) {
        front = YES;
    }else {
        front = NO;
    }
    if (self.qpRecordView.buttonSkin.selected) {
        beauty = YES;
    }else {
        beauty = NO;
    }
    if (self.qpRecordView.buttonTime.selected) {
        countDown = YES;
    }else {
        countDown = NO;
    }
    [[QPEventManager shared] event:QPEventRecordStart
                        withParams:@{@"beauty":beauty?@(1):@(0), @"countDown":countDown?@(1):@(0), @"front":front?@(1):@(0)}];     // 记录事件
}

- (void)onClickButtonRecordUpAction:(UIButton *)sender {
    self.qpRecordView.buttonTime.enabled = YES;
    
    self.recordStatus = QPRecordStatusPause;
    [self.recorder stopRecording];
    
}

- (void)onClickButtonFinishAction:(UIButton *)sender {
    
    NSDictionary *dic = [self.video toDictionary];
    NSLog(@"%@",dic);
    [self.video jsonToFile:[self.video fullPathForFileName:self.video.configFileName]];
    self.recordStatus = QPRecordStatusCombine;
    [self.recorder finishRecording];
    [[QPEventManager shared] event:QPEventRecordManualnext];
}


- (void)centerTapGestureAction:(UIGestureRecognizer *)sender {
    
    if(self.qpRecordView.sliderSkin.isHighlighted){
        return;
    }
    CGPoint point = [sender locationInView:self.qpRecordView.viewCenter];
    CGPoint percentPoint = CGPointZero;
    percentPoint.x = point.x / CGRectGetWidth(self.qpRecordView.viewCenter.bounds);
    percentPoint.y = point.y / CGRectGetHeight(self.qpRecordView.viewCenter.bounds);
    //    [[QURecord shared] setExposureValue:0.5];//自动调整到0.5
    [self.recorder focusAtAdjustedPoint:percentPoint];
}

- (void)centerPanGestureAction:(UIGestureRecognizer *)sender {
    
    if (_focusView.alpha == 0/* || _focusView.autoFocus*/) {
        return;
    }
    
    CGPoint point = [(UIPanGestureRecognizer *)sender translationInView:self.qpRecordView.viewCenter];
    point = [self.qpRecordView.viewFocusContent convertPoint:point fromView:self.qpRecordView.viewCenter];
    CGFloat y = point.y;
    if (sender.state == UIGestureRecognizerStateBegan) {
        _lastPanY = y;
    }
    CGFloat v = (_lastPanY - y)/CGRectGetWidth(self.qpRecordView.viewCenter.bounds)*0.5;
    [self.recorder setExposureValue:v + self.recorder.exposureValue];
    _lastPanY = y;

}

- (void)centerPinchGestureAction:(UIGestureRecognizer *)sender {
    
    if (sender.numberOfTouches != 2) {
        return;
    }
    CGPoint p1 = [sender locationOfTouch:0 inView:self.qpRecordView.viewCenter];
    CGPoint p2 = [sender locationOfTouch:1 inView:self.qpRecordView.viewCenter];
    CGFloat dx = (p2.x - p1.x);
    CGFloat dy = (p2.y - p1.y);
    CGFloat dist = sqrt(dx*dx + dy*dy);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _lastPinchDistance = dist;
    }
    CGFloat change = dist - _lastPinchDistance;
    change = change / (CGRectGetWidth(self.qpRecordView.viewCenter.bounds) * 0.8) * 2.0;
    [self.recorder zoomCamera:change];
    _lastPinchDistance = dist;

}

- (void)skinSliderValueChanged:(UISlider *)sender {
    
    [self.recorder changeSkinFilterValue:self.qpRecordView.sliderSkin.value];
    self.qpRecordView.labelSkinRight.text = [NSString stringWithFormat:@"%0.0f%%",self.qpRecordView.sliderSkin.value * 100];
}

- (void)skinSliderTouchDown:(UISlider *)sender {
    
    [self.recorder changeSkinFilterValue:self.qpRecordView.sliderSkin.value];
    [self.qpRecordView.labelSkinRight setHidden:NO];
    self.qpRecordView.labelSkinRight.text = [NSString stringWithFormat:@"%0.0f%%",self.qpRecordView.sliderSkin.value * 100];
}

- (void)skinSliderTouchCancel:(UISlider *)sender {

    [self.recorder changeSkinFilterValue:self.qpRecordView.sliderSkin.value];
    self.qpRecordView.labelSkinRight.text = [NSString stringWithFormat:@"%0.0f%%",self.qpRecordView.sliderSkin.value * 100];
    [self.qpRecordView.labelSkinRight setHidden:YES];
}

- (void)viewBottomTouchDownAction:(UIGestureRecognizer *)sender {
   
    if (![self.video isEmpty] && self.recordStatus == QPRecordStatusTrash) {
        self.recordStatus = QPRecordStatusPause;
        [_tipGuideView removeAllGuideView];
    }
}


#pragma mark - Makeup Animation

-(void)displayMakeupAnimatedImage {
    if (!_makeupAnimatedImage) {
        _makeupAnimatedImage = [[UIImageView alloc]initWithImage:[UIImage animatedImageWithImages:_makeupImageFrames duration:1]];
        _makeupAnimatedImage.frame = self.qpRecordView.viewCenter.bounds;
        _makeupAnimatedImage.userInteractionEnabled = NO;
        [self.qpRecordView.viewCenter addSubview:_makeupAnimatedImage];
    }
}

-(void)removeMakeupAnimatedImage {
    [_makeupAnimatedImage removeFromSuperview];
    _makeupAnimatedImage = nil;
}

#pragma mark - Record Handle

- (void)finishRecord {
    [self.recorder stopPreview];
    [self.video synchronizeToDisk];
    _startEncodingTime = [[NSDate date] timeIntervalSince1970];
//    [self.video combineVideoWithCompletionBlock:^(NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self finishRecordHandleWithError:error];
//        });
//    }];
    [self finishRecordHandleWithError:nil];
}

- (void)finishRecordHandleWithError:(NSError *)error {
    [self.qpRecordView.activityIndicator stopAnimating];
    self.qpRecordView.buttonFinish.enabled = YES;
    self.qpRecordView.buttonRecord.enabled = YES;
    self.qpRecordView.buttonLibrary.enabled = YES;
    self.qpRecordView.viewCenter.userInteractionEnabled = YES;
    self.qpRecordView.viewBottom.userInteractionEnabled = YES;
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
    _actionSheet = nil;
    if (error) {
        [[QPProgressHUD sharedInstance] showtitleNotic:@"合成视频失败！"];
        if (_recordStatus == QPRecordStatusCombine) {
            [self.video letVideoDurationLessMaxDuration];
            self.recordStatus = QPRecordStatusReset;
            self.recordStatus = QPRecordStatusPause;
        }
        [self startToPreview];
    }else{
        
        if ([QupaiSDK shared].enableVideoEffect) {
            QPEffectViewController *controller = [[QPEffectViewController alloc] initWithNibName:@"QPEffectViewController" bundle:nil video:self.video];
            [self.navigationController pushViewController:controller animated:YES];
            
        }else{
            NSTimeInterval finishEncodingTime = [[NSDate date] timeIntervalSince1970];
            CGFloat encodingDuration = finishEncodingTime - _startEncodingTime;
            [[QPEventManager shared] event:QPEventEncodeFinish
                                withParams:@{@"duration":[NSNumber numberWithInt:encodingDuration * 1000],
                                             @"filter":@(0),
                                             @"music":@(0)}];
            NSURL *url = [self.video fullURLForFileName:self.video.recordFileName];
            NSURL *thumbnailURL = [QPVideo movieFirstFrame:url toPath:[self.video newUniquePathWithExt:@"jpg"]
                                                   quality:QupaiSDK.shared.thumbnailCompressionQuality];
            [[QupaiSDK shared] compelete:url.path thumbnailPath:thumbnailURL.path];
        }

    }
}

#pragma mark - Tool Methods 



- (void)finishRecordScale:(id)obj {
    self.qpRecordView.viewScale.hidden = YES;
}

- (void)finishRecordFocus:(id)obj {
    [_focusView stopAnimation];
}

#pragma mark - QPRecoord Delegate

- (void)recordWillStartPreview:(QPRecord *)record {
    self.qpRecordView.viewMask.hidden = YES;
    self.qpRecordView.viewCenter.userInteractionEnabled = YES;
    self.qpRecordView.viewBottom.userInteractionEnabled = YES;
    self.qpRecordView.pointProgress.hidden = NO;
    [self.qpRecordView.pointProgress updateProgress:0];
    [_guideView recordStart];
}

- (NSURL *)outputFileURLForRecording {
    QPVideoPoint *vp = [self.video addEmptyVideoPoint];
    vp.rotate = (360 - _deviceAngle)/90;
    return [self.video fullURLForFileName:vp.fileName];
}

- (void)record:(QPRecord *)record time:(float)time {
    [self.video updateLastVideoDuration:time];
    [_guideView recordTimeUpdate:self.video.duration];
}

- (void)recorDidStopRecording:(QPRecord *)record {
    if (self.qpRecordView.buttonRecord.highlighted) {
        [self.recorder startRecording];
    }
}

- (void)recordDidFinishRecording:(QPRecord *)record {
    [self finishRecord];
    if(_countDown){
        self.countDown = NO;
    }
}

- (void)recordWillStopCameraCapture:(QPRecord *)record {
    if (_countDown) {
        self.countDown = NO;
    }
}

- (void)recordWillStopPreview:(QPRecord *)record {
    _recordFlag.skin = record.skinFilterEnabled;
    _recordFlag.position = record.captureDevicePosition;
    self.qpRecordView.pointProgress.hidden = YES;
}

- (void)record:(QPRecord *)record scale:(CGFloat)scale {
    self.qpRecordView.labelScale.text = [NSString stringWithFormat:@"X %0.1f",scale];
    self.qpRecordView.viewScale.hidden = NO;
    [self finishRecordFocus:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(finishRecordScale:) withObject:nil afterDelay:1.0];
}

- (void)record:(QPRecord *)record willBeginFocusAtPoint:(CGPoint)point {
    point.x = point.x * CGRectGetWidth(self.qpRecordView.viewCenter.bounds);
    point.y = point.y * CGRectGetHeight(self.qpRecordView.viewCenter.bounds);
    
    if (!CGPointEqualToPoint(point, _focusView.center) || _focusView.alpha == 0) {
        _focusView.center = [self.qpRecordView.viewFocusContent convertPoint:point fromView:self.qpRecordView.viewCenter];
        [_focusView startAnimation];
        [self finishRecordScale:nil];
    }
}

- (void)record:(QPRecord *)record didEndFocusAtPoint:(CGPoint)point {
    [self finishRecordFocus:nil];
}

- (void)record:(QPRecord *)record exposureValue:(CGFloat)value percent:(CGFloat)percent {
    [_focusView changeExposureValue:percent];
}

- (void)record:(QPRecord *)record exposureDuration:(CMTime)duration iso:(CGFloat)iso {
    
}


#pragma mark - Picker Delegate

- (void)pickerPreviewViewController:(QPPickerPreviewViewController *)controller videoPath:(NSString *)path {
    [controller dismissViewControllerAnimated:NO completion:^{
        if (path) {
            [self.video addVideoPointByPath:path];
            if (self.video.duration < self.video.maxDuration) {
                [self onClickButtonFinishAction:nil];
            }
        }
    }];
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}
@end
