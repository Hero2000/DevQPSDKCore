//
//  QPMediaRender.h
//  QPSDKCore
//
//  Created by yly on 16/4/15.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QPMediaPack.h"

@protocol QPMediaRenderDelegate;

@interface QPMediaRender : NSObject

// Delegate
@property (nonatomic, weak) id<QPMediaRenderDelegate> delegate;

/**
 *  创建渲染
 *
 *  @param rect 渲染的rect范围
 *  @return     view
 */
+ (UIView *)createRenderViewWithFame:(CGRect)rect;

/**
 *  创建渲染
 *
 *  @param pack 视频包
 *  @return     渲染器
 */
- (instancetype)initWithMediaPack:(QPMediaPack *)pack;

/**
 *  开始渲染
 *
 *  @param view 渲染的view
 */
- (void)startRenderToView:(UIView *)view;
/**
 *  开始输出
 *
 */
- (void)startExport;

/**
 *  离开
 *
 */
- (void)cancel;

/**
 *  播放模式（播放与合成，合成播放速度会变快）
 *
 *  @return 是否是播放
 */
- (BOOL)isPlayMode;

/**
 *  播放和暂停
 *
 */
- (void)playOrPause;

/**
 *  播放结束
 *
 *  @param handler 输出URL
 */
- (void)finishRecordingWithCompletionHandler:(void (^)(NSURL *url))handler;
@end


@protocol QPMediaRenderDelegate <NSObject>

/**
 *  结束渲染
 *
 *  @param render 渲染器
 */
- (void)mediaRenderCancel:(QPMediaRender *)render;

/**
 *  获取当前视频导出进度
 *
 *  @param render 渲染器
 */
- (void)currentVideoCompositionWithPlan:(CGFloat)plan;

@end