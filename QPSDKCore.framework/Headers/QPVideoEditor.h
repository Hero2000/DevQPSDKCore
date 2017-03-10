//
//  QPVideoEditor.h
//  QPSDKCore
//
//  Created by Worthy on 16/9/18.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface QPVideoEditor : NSObject

- (void)exportVideoAVAsset:(AVAsset *)asset
                     range:(CMTimeRange)range
                      rect:(CGRect)rect
                      size:(CGSize)size
                   bitRate:(NSInteger)bitRate
                     toURL:(NSURL *)toURL
              percentBlock:(void(^)(CGFloat percent))percentBlock
             completeBlock:(void(^)(NSURL *filePath))completeBlock;

- (void)cancel;
@end
