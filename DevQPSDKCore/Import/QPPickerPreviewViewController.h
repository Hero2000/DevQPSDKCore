//
//  DraftsViewController.h
//  duanqu2
//
//  Created by lyle on 14-2-19.
//  Copyright (c) 2014年 duanqu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QPBaseViewController.h"
#import "QPCutViewController.h"
#import "QPVideo.h"

@protocol QPPickerPreviewViewControllerDelegate;

@interface QPPickerPreviewViewController : QPBaseViewController
<MBProgressHUDDelegate, QPCutViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) UIView *colletionHeadView;

@property (weak, nonatomic) id<QPPickerPreviewViewControllerDelegate> delegate;

@end

@protocol QPPickerPreviewViewControllerDelegate  <NSObject>

- (void)pickerPreviewViewController:(QPPickerPreviewViewController *)controller videoPath:(NSString *)path;

@end



