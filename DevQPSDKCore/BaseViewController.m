//
//  BaseViewController.m
//  DevQPSDKCore
//
//  Created by LYZ on 16/4/29.
//  Copyright © 2016年 duanqu. All rights reserved.
//

#import "BaseViewController.h"
#import <QPSDKCore/QPSDKCore.h>
#import <QPSDKCore/QPAuth.h>
#import <QPSDKCore/QPVideoEditor.h>
#import "QPRecordViewController.h"
#import "QPEffectMusic.h"
#import "QPPickerPreviewViewController.h"
#import "QPNavigationController.h"

@interface BaseViewController ()<QupaiSDKDelegate>
@property (nonatomic, strong) QPVideoEditor *editor;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)qupaiSDK:(id<QupaiSDKDelegate>)sdk compeleteVideoPath:(NSString *)videoPath thumbnailPath:(NSString *)thumbnailPath{
    NSLog(@"Qupai SDK compelete %@",videoPath);
    [self dismissViewControllerAnimated:YES completion:nil];
    if (videoPath) {
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, nil, nil, nil);
    }
    if (thumbnailPath) {
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:thumbnailPath], nil, nil, nil);
    }
}

- (NSArray *)qupaiSDKMusics:(id<QupaiSDKDelegate>)sdk
{
//    NSString *baseDir = [[NSBundle mainBundle] bundlePath];
//    NSString *configPath = [[NSBundle mainBundle] pathForResource:1 ? @"music2" : @"music1" ofType:@"json"];
//    NSData *configData = [NSData dataWithContentsOfFile:configPath];
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingAllowFragments error:nil];
//    NSArray *items = dic[@"music"];
    
    NSMutableArray *array = [NSMutableArray array];
    
    QPEffectMusic *effect = [[QPEffectMusic alloc] init];
    effect.name = @"audio";
    effect.eid = 1;
    effect.musicName = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"mp3"];
    effect.icon = [[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"];
    [array addObject:effect];

    return array;
}

- (IBAction)recordButtonClicked:(id)sender {
    [QupaiSDK shared].maxDuration = 30.0;
    UIViewController *controller = [[QupaiSDK shared] createRecordViewController];
    [QupaiSDK shared].delegte = self;
    [QupaiSDK shared].videoSize = CGSizeMake([_widthLabel.text integerValue], [_heightLabel.text integerValue]);
    QPNavigationController *nav = [[QPNavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
    
    
}

- (IBAction)tapHandler:(UITapGestureRecognizer *)sender {
    [self.widthLabel resignFirstResponder];
    [self.heightLabel resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editButtonClicked:(id)sender {
    [QupaiSDK shared].videoSize = CGSizeMake([_widthLabel.text integerValue], [_heightLabel.text integerValue]);
    QPPickerPreviewViewController *pickerVC = [[QPPickerPreviewViewController alloc] initWithNibName:@"QPPickerPreviewViewController" bundle:nil];
    pickerVC.delegate = self;
    QPNavigationController *naviVC = [[QPNavigationController alloc] initWithRootViewController:pickerVC];
    [self presentViewController:naviVC animated:YES completion:nil];
}

#pragma mark - delegate

-(void)pickerPreviewViewController:(QPPickerPreviewViewController *)controller videoPath:(NSString *)path {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
        if (path) {
            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
        }
    });
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
