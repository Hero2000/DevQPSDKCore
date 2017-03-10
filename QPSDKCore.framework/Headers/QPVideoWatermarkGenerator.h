//
//  QPVideoWatermarkGenerator.h
//  GPUImageDemo
//
//  Created by zhangwx on 16/7/25.
//  Copyright © 2016年 Worthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol QPVideoWatermarkGeneratorDegelate <NSObject>

-(void)videoWatermarkGenerationFinshed:(NSURL *)fileUrl;
@optional
-(void)videoWatermarkGenerationFailed:(NSError *)error;
@end

@interface QPVideoWatermarkGenerator : NSObject
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) UIImage *watermarkImage;
@property (nonatomic, assign) CGSize watermarkSize;
@property (nonatomic, strong) NSURL *outputUrl;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) NSUInteger bitRate;
@property (nonatomic, weak) id<QPVideoWatermarkGeneratorDegelate> delegate;

- (void)generateWithCompleteHandler:(void(^)(NSError *error, NSURL *url))handler;

- (void)generateVideoWithImage:(UIImage *)image watermark:(UIImage *)watermark outputFileUrl:(NSURL *)fileUrl;
@end
