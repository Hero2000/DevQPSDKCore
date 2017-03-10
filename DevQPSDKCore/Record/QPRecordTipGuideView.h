//
//  QPRecordTipGuideView.h
//  QupaiSDK
//
//  Created by yly on 15/6/29.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QPRecordTipGuideView : UIView

- (void)addSkinGuideInPoint:(CGRect)frame;
- (void)addImportGuideInPoint:(CGRect)frame;
- (void)addDeleteGuideInPoint:(CGRect)frame;
- (void)addDeleteTrashGuideInPoint:(CGRect)frame;

- (void)removeAllGuideView;
@end
