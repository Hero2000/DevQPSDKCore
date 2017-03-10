//
//  QPEventManager.h
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 15/12/23.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

//static NSString* const QPEventStart = @"start";
//static NSString* const QPEventRecordStart = @"record_start";
//static NSString* const QPEventRecordFinish = @"record_finish";
//static NSString* const QPEventImportVideo = @"import_video";

// 编码完成
static NSString* const QPEventEncodeFinish = @"encode_finish";

// 启动SDK
static NSString* const QPEventStart = @"start";
// 录制_启动录制
static NSString* const QPEventRecordStart = @"record_start";
// 录制_录制完成
static NSString* const QPEventRecordFinish = @"record_finish";
// 录制_导入
static NSString* const QPEventImportVideo = @"import_video";
// 录制_手动完成
static NSString* const QPEventRecordManualnext = @"record_manualnext";
// 录制_自动完成
static NSString* const QPEventRecordAutonext = @"record_autonext";
// 录制_退出
static NSString* const QPEventRecordQuit = @"record_quit";
// 录制_放弃录制
static NSString* const QPEventRecordAbandon = @"record_abandon";
// 录制_重新录制
static NSString* const QPEventRecordRetake = @"record_retake";
// 录制_确认回删
static NSString* const QPEventRecordDeleteConfirm = @"record_delete_confirm";
//// 录制_开前置
//static NSString* const QPEventRecordFronton = @"record_fronton";
//// 录制_关前置
//static NSString* const QPEventRecordFrontoff = @"record_frontoff";
//// _开启定时
//static NSString* const QPEventRecordCountdownOn = @"record_countdown_on";
//// _关闭定时
//static NSString* const QPEventRecordCountdownOff = @"record_countdown_off";
//// 录制_开美颜
//static NSString* const QPEventRecordBeautyon = @"record_beautyon";
//// 录制_关美颜
//static NSString* const QPEventRecordBeautyoff = @"record_beautyoff";
// 导入_导入本地视频
static NSString* const QPEventImportLocal = @"import_local";
// 导入_选择相薄
static NSString* const QPEventImportAlbum = @"import_album";
// 导入_选取成功
//static NSString* const QPEventImportSelectOk = @"import_select_ok";
// 导入_裁剪完成
static NSString* const QPEventImportCutOk = @"import_cut_ok";
//// 编辑_返回
//static NSString* const QPEventEditBack = @"edit_back";
// 编辑_下一步
static NSString* const QPEventEditNext = @"edit_next";
//// 滤镜_原片
//static NSString* const QPEventFilterNo = @"filter_no";
//// 滤镜_有滤镜
//static NSString* const QPEventFilterYes = @"filter_yes";
//// 音乐_原音
//static NSString* const QPEventMusicNo = @"music_no";
//// 音乐_有音乐
//static NSString* const QPEventMusicYes = @"music_yes";
//// 网络类型
//static NSString* const QPEventNetwork = @"network";
//// 运营商
//static NSString* const QPEventCarrieroperator = @"carrieroperator";

@interface QPEventManager : NSObject

+ (instancetype)shared;

- (void)event:(NSString *)event;
- (void)event:(NSString *)event withParams:(NSDictionary *)params;

- (void)uploadEvents;
- (void)uploadAppInfo;
@end
