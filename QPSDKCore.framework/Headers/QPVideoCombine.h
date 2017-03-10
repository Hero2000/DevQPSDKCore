//
// Copyright (c) 2013 Carson McDonald
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions
// of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface QPVideoCombine : NSObject

@property (nonatomic, assign) BOOL shouldOptimizeForNetworkUse;



- (id)initWithOutputSize:(CGSize)outSize;

/**
 *  添加视频
 *
 *  @param asset   视频
 *  @param rotate  方向
 *  @param error   错误信息
 */
- (void)addAsset:(AVURLAsset *)asset rotate:(NSInteger)rotate withError:(NSError **)error;

/**
 *  输出视频
 *
 *  @param outputfile  输出路径
 *  @param preset      视频质量
 *  @param completed   错误block
 */
- (void)exportTo:(NSURL *)outputFile withPreset:(NSString *)preset withCompletionHandler:(void (^)(NSError *error))completed;


/**
 *  输出视频
 *
 *  @param outputfile  输出路径
 *  @param preset      视频质量
 *  @param waterMark   水印图片
 *  @param completed   错误block
 */
- (void)exportTo:(NSURL *)outputFile withPreset:(NSString *)preset waterMark:(UIImage *)waterMark completionHandler:(void (^)(NSError *error))completed;

@end