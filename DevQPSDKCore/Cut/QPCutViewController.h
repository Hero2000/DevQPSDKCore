//
//  QPCutViewController.h
//  QupaiSDK
//
//  Created by lyle on 14-3-17.
//  Copyright (c) 2014年 lyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QPBaseViewController.h"

@class QPCutInfo;

@protocol QPCutViewControllerDelegate;

@interface QPCutViewController : QPBaseViewController

@property (weak, nonatomic) id<QPCutViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil cutInfo:(QPCutInfo *)cutInfo;


@end

@protocol QPCutViewControllerDelegate <NSObject>

- (void)cutViewControllerFinishCut:(NSString *)path;

@end
