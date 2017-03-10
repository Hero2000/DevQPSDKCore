//
//  CutVideo.h
//  duanqu2
//
//  Created by lyle on 1/20/14.
//  Copyright (c) 2014 duanqu. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@protocol QPCutVideoDelegate <NSObject>

/**
 *  视频裁剪合成失败
 */
- (void)cutAndCompressVideoSuccess:(NSURL *)fileURL;

/**
 *  视频裁剪合成成功
 *
 */
- (void)cutAndCompressVideofailure:(NSError *)error;

/**
 *  当前视频合成进度（不包含裁剪）
 *
 */
- (void)currentCompressPlan:(CGFloat)plan;


@end

@interface QPCutVideo : NSObject

@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) AVMutableComposition *mutableComposition;

@property (nonatomic, weak)id<QPCutVideoDelegate> delegate;

- (void)cutVideoAVAsset:(AVAsset *)asset range:(CMTimeRange)range offset:(CGPoint)offset size:(CGSize)size presetName:(NSString *)presetName toURL:(NSURL *)toURL
          completeBlock:(void(^)(NSURL *filePath))block;
- (void)cutVideoAVAsset:(AVAsset *)asset range:(CMTimeRange)range waterMark:(UIImage *)waterMark offset:(CGPoint)offset size:(CGSize)size presetName:(NSString *)presetName toURL:(NSURL *)toURL
          completeBlock:(void(^)(NSURL *filePath))block;

/**
 *  视频裁剪+视频合成
 *
 *  @param asset      视频asset
 *  @param range      range
 *  @param offset     offset
 *  @param waterMark  水印
 *  @param size       size
 *  @param bitrate    码率
 *  @param presetName 建议：AVAssetExportPresetHighestQuality
 *  @param toURL      输出URL
 */
- (void)cutVideoAndCompressAVAsset:(AVAsset *)asset range:(CMTimeRange)range offset:(CGPoint)offset waterMark:(UIImage *)waterMark size:(CGSize)size bitrate:(NSInteger)bitrate presetName:(NSString *)presetName toURL:(NSURL *)toURL;

@end
