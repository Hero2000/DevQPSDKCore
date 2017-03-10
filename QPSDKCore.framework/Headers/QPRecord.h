//
//  QURecord.h
//  QUPAI3_RECORD
//
//  Created by yly on 14-9-15.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QPRecordType) {
    QPRecordVideo,
    QPRecordPhoto
};


@protocol QPRecordDelegate;

@interface QPRecord : NSObject
// Delegate
@property (nonatomic, weak) id<QPRecordDelegate> delegate;
// 是否开启美颜
@property (nonatomic, assign) BOOL skinFilterEnabled;
// 曝光值
@property (nonatomic, assign) CGFloat exposureValue;
// 电筒模式
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
// 闪光灯模式
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
// 摄像头位置
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;
// 录制类型
@property (nonatomic, assign) QPRecordType recordType;
// 是否正在录制
@property (nonatomic, assign, readonly) BOOL isRecording;
// 是否有闪光灯
@property(nonatomic, assign, readonly) BOOL hasFlash;
// 预览画面
@property (nonatomic, strong, readonly) CALayer *previewLayer;


/**
 *  开始拍摄预览
 *
 *  @param videoSize 分辨率
 *  @param position  摄像头位置
 *  @param bitRate   码率
 *  @param skin      是否美颜
 */
- (void)startPreviewWithVideoSize:(CGSize)videoSize
                         position:(AVCaptureDevicePosition)position
                          bitRate:(NSInteger)bitRate
                             skin:(BOOL)skin;
/**
 *  开始拍摄预览
 *
 *  @param videoSize 分辨率
 *  @param position  摄像头位置
 *  @param skin      是否美颜
 */
- (void)startPreviewWithVideoSize:(CGSize)videoSize
                         position:(AVCaptureDevicePosition)position
                             skin:(BOOL)skin;
/**
 *  开始拍摄预览
 *
 *  @param videoSize 分辨率
 */
- (void)startPreviewWithVideoSize:(CGSize)videoSize;

/**
 *  结束拍摄预览
 */
- (void)stopPreview;

/**
 *  开始拍摄视频
 */
- (void)startRecording;
/**
 *  结束拍摄视频
 */
- (void)stopRecording;

/**
 *  完成拍摄会话，回收资源
 */
- (void)finishRecording;


/**
 *  切换摄像头位置
 *
 *  @return 切换后的摄像头位置
 */
- (AVCaptureDevicePosition)switchCameraPosition;

/**
 *  切换闪光灯模式
 *
 *  @return 切换后的闪光灯模式
 */
- (AVCaptureTorchMode)switchTorchMode;

/**
 *  切换闪光灯模式
 *
 *  @return 切换后的闪光灯模式
 */
- (AVCaptureFlashMode)switchFlashMode;

/**
 *  对焦
 *
 *  @param adjustedPoint 对焦位置 (0, 0)~(1, 1)
 */
- (void)focusAtAdjustedPoint:(CGPoint)adjustedPoint;

/**
 *  变焦
 *
 *  @param zoom 变焦系数
 */
- (void)zoomCamera:(CGFloat)zoom;

/**
 *  调节美颜度
 *
 *  @param value 美颜度 0~1
 */
- (void)changeSkinFilterValue:(CGFloat)value;

/**
 *  截图
 *
 *  @return 截取的图片
 */
- (UIImage *)snapImage;

@end

@protocol QPRecordDelegate <NSObject>

/**
 *  初始化工作完成，准备开始预览
 *
 *  @param record QPRecord
 */
- (void)recordWillStartPreview:(QPRecord *)record;

/**
 *  输出路径,调用startRecording后触发
 *
 *  return 视频输出路径
 */
- (NSURL *)outputFileURLForRecording;

/**
 *  正在录制视频的时长
 *
 *  @param record QPRecord
 *  @param time   时长
 */
- (void)record:(QPRecord *)record time:(float)time;

/**
 *  录制视频已结束，调用stopRecording后触发
 *
 *  @param record QPRecord
 */
- (void)recorDidStopRecording:(QPRecord *)record;

/**
 *  录制会话已完成，调用finishRecording后触发
 *
 *  @param record QPRecord
 */
- (void)recordDidFinishRecording:(QPRecord *)record;

/**
 *  即将结束预览，调用stopPreview方法后触发
 *
 *  @param record QPRecord
 */
- (void)recordWillStopPreview:(QPRecord *)record;

/**
 *  即将停止摄像头，应用退到后台时触发
 *
 *  @param record QPRecord
 */
- (void)recordWillStopCameraCapture:(QPRecord *)record;

/**
 *  焦距调节倍数
 *
 *  @param record QPRecord
 *  @param scale  调节倍数
 */
- (void)record:(QPRecord *)record scale:(CGFloat)scale;

/**
 *  即将开始对焦
 *
 *  @param record QPRecord
 *  @param point  对焦点
 */
- (void)record:(QPRecord *)record willBeginFocusAtPoint:(CGPoint)point;

/**
 *  结束已对焦
 *
 *  @param record QPRecord
 *  @param point  对焦点
 */
- (void)record:(QPRecord *)record didEndFocusAtPoint:(CGPoint)point;

/**
 *  曝光
 *
 *  @param record  QPRecord
 *  @param value   曝光值(倍数)
 *  @param percent 曝光值(百分比)
 */
- (void)record:(QPRecord *)record exposureValue:(CGFloat)value percent:(CGFloat)percent;

/**
 *  曝光
 *
 *  @param record   QPRecord
 *  @param duration 时长
 *  @param iso      iso
 */
- (void)record:(QPRecord *)record exposureDuration:(CMTime)duration iso:(CGFloat)iso;

@end
