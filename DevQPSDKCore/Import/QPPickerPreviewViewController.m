//
//  DraftsViewController.m
//  duanqu2
//
//  Created by lyle on 14-2-19.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#include <MobileCoreServices/MobileCoreServices.h>
#import "QPPickerPreviewViewController.h"
#import "QPPickerPreviewCell.h"
#import "QPPickerLibraray.h"
#import "QPCutInfo.h"
#import "QPLibrarayItem.h"
#import "QPEventManager.h"

#import "QPPickerPreviewView.h"

@interface QPPickerPreviewViewController ()<QPPickerPreviewViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    AVPlayer *_avPlayer;
    AVPlayerLayer *_playerLayer;
    NSUInteger _curIndex;
    NSArray *_array;
    
    QPProgressHUD *HUD;
    BOOL _finishLoadData;
    
    ALAssetsLibrary *_library;
    BOOL _viewDisplay;/*view 是否显示， 相册有变动，会更新，导致播放视频*/
    BOOL _permissionDenied;
}

@property (nonatomic, strong) QPPickerPreviewView *qpPreviewView;

@end

@implementation QPPickerPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    
    self.qpPreviewView = [[QPPickerPreviewView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.qpPreviewView.delegate = self;
    self.view = self.qpPreviewView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.qpPreviewView.collectionView registerNib:[UINib nibWithNibName:@"QPPickerPreviewCell" bundle:[QPBundle mainBundle]] forCellWithReuseIdentifier:@"QPPickerPreviewCell"];
    [self.qpPreviewView.collectionView registerClass:[QPPickerPreviewCell class] forCellWithReuseIdentifier:@"QPPickerPreviewCell"];
    self.qpPreviewView.collectionView.delegate = self;
    self.qpPreviewView.collectionView.dataSource = self;
    [self addNotification];
    
    self.qpPreviewView.oneLineNoticeLabel.text = [NSString stringWithFormat:@"%@无法访问视频",[[QupaiSDK shared] appName]];
    self.qpPreviewView.threeLineNoticeLabel.text = [NSString stringWithFormat:@"将%@设置为开启。",[[QupaiSDK shared] appName]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    _viewDisplay = YES;

    self.qpPreviewView.viewNotice.hidden = YES;
    self.qpPreviewView.viewCenter.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkAutorization:^(BOOL granted) {
        if (granted) {
            [self loadData];
            _viewDisplay = YES;
        }else{
            _permissionDenied = YES;
            [self tableViewReloadata];
        }
    }];
    
    if ([QPSDKConfig is35] && !QPSave.shared.importDurationGuide) {
        QPSave.shared.importDurationGuide = YES;
        [[QPProgressHUD sharedInstance] showtitleNotic:@"仅支持导入10分钟之内的视频" time:3];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _viewDisplay = NO;
    [self destroyResources];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkAutorization:(void (^)(BOOL granted))handler
{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined){
        [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                handler(YES);
            }
            *stop = YES;
        } failureBlock:^(NSError *error) {
            handler(NO);
        }];
    }else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
        handler(NO);
    }else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        handler(YES);
    }
}

- (void)loadData
{
    if (_finishLoadData) {
        [self playVideoAtIndex:_curIndex];
        return;
    }else{
        _library = [[ALAssetsLibrary alloc] init];
    }
    if (HUD) {
        [HUD hide:YES];
    }
    HUD = [[QPProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"正在加载...";
    [HUD show:YES];

    [self importAllVideos];
}

- (void)importAllVideos
{
    QPPickerLibraray *tool = [[QPPickerLibraray alloc] init];
    tool.library = _library;
    tool.groupType = ALAssetsGroupSavedPhotos;
    tool.groupName = nil;
    [tool setItemsCompleteBlock:^(NSArray *a, NSInteger c) {
        [HUD hide:YES];
        _array = a;
        _finishLoadData = YES;
        [self tableViewReloadata];
    }];
    [tool startLibrary];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (![QPSDKConfig is35]){
        self.qpPreviewView.labelVideoCount.text = [NSString stringWithFormat:@"%zd 个视频(仅支持少于10分钟)",_array.count];
    }
    return [_array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QPPickerPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QPPickerPreviewCell" forIndexPath:indexPath];
    QPLibrarayItem *item = _array[indexPath.row];
    
    NSInteger duration = (int)ceil(item.duration);
    cell.labelDuration.text = [NSString stringWithFormat:@"%02zd:%02zd",(int)duration/60, duration%60];
    cell.imageViewIcon.image = item.image;
    cell.imageViewFlag.image = [self imageForVideoSubtype:item.type];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self playVideoAtIndex:indexPath.row];
}

- (UIImage *)imageForVideoSubtype:(QPLibrarayItemType)subtype
{
    if (subtype == QPLibrarayItemTypeHighFrameRate) {
        return [QPImage imageNamed:@"ico_slowmotion"];
    }else if (subtype == QPLibrarayItemTypeTimelapse) {
        return [QPImage imageNamed:@"ico_delay"];
    }
    return [QPImage imageNamed:@"camera"];
}

#pragma mark - AVPlayer

- (void)setAVPlayerByAsset:(AVAsset *)asset volume:(CGFloat)volume
{
    NSLog(@"view display %d %@",_viewDisplay, _avPlayer);
    if (!_viewDisplay) {
        return;
    }
    if (_avPlayer == nil) {
        AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
        _avPlayer = [AVPlayer playerWithPlayerItem:anItem];
        
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
//        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        playerLayer.backgroundColor = [[UIColor clearColor] CGColor];
        playerLayer.frame = self.qpPreviewView.viewPlayer.layer.bounds;
        [self.qpPreviewView.viewPlayer.layer addSublayer:playerLayer];
        
        _playerLayer = playerLayer;
    }
    
    [_avPlayer seekToTime:kCMTimeZero];
    [_avPlayer play];
}

- (void)destroyPlayer
{
    [_avPlayer pause];
    _avPlayer = nil;
    
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
}

- (void)pausePlayer
{
    [_avPlayer pause];
}

- (void)destroyPlayerNotLayer
{
    [_avPlayer pause];
    _avPlayer = nil;
}

- (void)dealloc
{
    [self removeNotification];
}

- (void)destroyResources
{
    [self destroyPlayer];
    NSArray *sublayers = self.qpPreviewView.viewPlayer.layer.sublayers;
    [sublayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AVPlayerLayer *layer = (AVPlayerLayer *)obj;
        if ([layer isKindOfClass:[AVPlayerLayer class]]) {
            layer.player = nil;
            [layer removeFromSuperlayer];
            layer = nil;
        }
    }];
}

- (void)playVideoAtIndex:(NSInteger)index
{
    NSUInteger count = _array.count;
    if (index >= count) {
        index = count -1;
    }
    if (index < 0) {
        index = 0;
    }
    if (0 <= index && index < count) {
        QPLibrarayItem *item = _array[index];
        [self destroyPlayerNotLayer];
        
        AVAsset * asset = [item asset];
        [self setAVPlayerByAsset:asset volume:1];
    
        _curIndex = index;
        
        self.qpPreviewView.buttonFinish.enabled = YES;
        self.qpPreviewView.viewCenter.hidden = NO;
        self.qpPreviewView.viewNotice.hidden = YES;
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:_curIndex inSection:0];
        [self.qpPreviewView.collectionView selectItemAtIndexPath:ip animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }else{
        [self destroyPlayer];
        
        _curIndex = 0;
        self.qpPreviewView.buttonFinish.enabled = NO;
        self.qpPreviewView.viewCenter.hidden = YES;
        self.qpPreviewView.viewNotice.hidden = NO;
        self.qpPreviewView.labbelNotice.text = @"你还没有本地视频";
        self.qpPreviewView.viewPermission.hidden = !_permissionDenied;
        self.qpPreviewView.labbelNotice.hidden = _permissionDenied;
    }
}

#pragma mark - Private

- (void)gotoCutViewControllerByAsset:(AVAsset *)asset
{
    QPCutInfo *cutInfo = [[QPCutInfo alloc] init];
    CGFloat videoDuration = MAX(CMTimeGetSeconds(asset.duration), 8);
    CGFloat maxDuration = [QupaiSDK shared].maxDuration;
    cutInfo.cutMaxDuration = MIN(videoDuration, maxDuration);
//    cutInfo.cutMaxDuration = [QupaiSDK shared].maxDuration;
    cutInfo.cutMinDuration = [QupaiSDK shared].minDuration;
    [cutInfo setupWithAVAsset:asset];
    QPCutViewController *cut = [[QPCutViewController alloc] initWithNibName:@"QPCutViewController" bundle:[QPBundle mainBundle] cutInfo:cutInfo];
    cut.delegate = self;
    [self.navigationController pushViewController:cut animated:YES];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *pickerURL = info[UIImagePickerControllerMediaURL];
    AVURLAsset *asset = [AVURLAsset assetWithURL:pickerURL];
    if (!asset) {
        [picker popViewControllerAnimated:YES];
        [[QPProgressHUD sharedInstance] showtitleNotic:@"导出失败！"];
        return;
    }
    if (CMTimeGetSeconds(asset.duration) < QupaiSDK.shared.minDuration) {
        [picker popViewControllerAnimated:YES];
        [[QPProgressHUD sharedInstance] showtitleNotic:[NSString stringWithFormat:@"视频时长不能小于%0.0f秒",QupaiSDK.shared.minDuration] time:3.0];
        return;
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        [self gotoCutViewControllerByAsset:asset];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

- (void)pickerPreviewViewController:(QPPickerPreviewViewController *)controller selectVideo:(QPVideo *)video
{
    [controller dismissViewControllerAnimated:YES completion:^{
        _viewDisplay = YES;
    }];
}

#pragma mark - CuitViewController Delegate

- (void)cutViewControllerFinishCut:(NSString *)path
{
    [_delegate pickerPreviewViewController:self videoPath:path];
}

#pragma mark - Notification

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(assetsLibraryChangedNotification:)
                                                 name:ALAssetsLibraryChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:)
                                            name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    if (_avPlayer == nil || notification.object != _avPlayer.currentItem) {
        return;
    }
    [_avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [_avPlayer play];
        }
    }];
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    if (!_viewDisplay) {
        return;//导入相簿界面
    }
    _viewDisplay = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0 ||
        [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        _finishLoadData = NO;
        [self loadData];
    }else{
        [self playVideoAtIndex:_curIndex];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    _viewDisplay = NO;
    [self destroyPlayerNotLayer];
    sleep(1.0);
    NSLog(@"DraftsViewControlle background");
}

- (void)assetsLibraryChangedNotification:(NSNotification *)notification
{
    _finishLoadData = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
    });
}
#pragma mark - Action

- (void)onClickButtonCloseAction:(UIButton *)sender {
    
    _viewDisplay = NO;
    [self destroyPlayer];
    [_delegate pickerPreviewViewController:self videoPath:nil];
}

- (void)onClickButtonFinishAction:(UIButton *)sender {
    
    [self onClickButtonSelectAction:nil];
}

- (void)onClickButtonSelectAction:(UIButton *)sender {
    
    _viewDisplay = NO;// view 不显示，不在播放视频
    
    QPLibrarayItem *item = _array[_curIndex];
    [self gotoCutViewControllerByAsset:item.asset];
    
    [self destroyPlayerNotLayer];
    [[QPEventManager shared] event:QPEventImportLocal];
}


- (void)tableViewReloadata
{
    if (!_colletionHeadView) {
        CGFloat h = [QPSDKConfig isBig40] ? 80 : 80;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-54-5, 0, 54+5, h)];
        UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 54, h)];
        control.backgroundColor = [QupaiSDK shared].tintColor;
        [control addTarget:self action:@selector(tableviewHeadClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:control];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 47, 54, 16)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"相簿";
        [view addSubview:label];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 54, 22)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = [QPImage imageNamed:@"input_ico_album"];
        [view addSubview:imageView];
        
        [self.qpPreviewView.collectionView addSubview:view];
        _colletionHeadView = view;
    }
    self.qpPreviewView.collectionView.contentInset = UIEdgeInsetsMake(0, 54+5, 0, 0);
    [self.qpPreviewView.collectionView reloadData];
    [self playVideoAtIndex:_curIndex];
}
- (void)tableviewHeadClick:(UIControl *)control
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.allowsEditing = YES;
    picker.videoMaximumDuration = 60 * 10;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    _viewDisplay = NO;
    [[QPEventManager shared] event:QPEventImportAlbum];
}

#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(QPProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}
@end
