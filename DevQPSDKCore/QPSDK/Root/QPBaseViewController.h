//
//  QPBaseViewController.h
//  QupaiSDK
//
//  Created by yly on 15/6/17.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QPVideo.h"

@interface QPBaseViewController : UIViewController

@property (nonatomic, strong, readonly) QPVideo *video;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil video:(QPVideo *)video;

@end
