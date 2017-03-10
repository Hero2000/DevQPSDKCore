//
//  QPBaseViewController.m
//  QupaiSDK
//
//  Created by yly on 15/6/17.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QPBaseViewController.h"

@implementation QPBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil video:(QPVideo *)video
{
    if (!nibBundleOrNil) {
        nibBundleOrNil = [QPBundle qp_bundle];
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _video = video;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    NSLog(@"%@",NSStringFromClass([self class]));
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
