//
//  QPPrefixHead.h
//  QupaiSDK
//
//  Created by yly on 15/6/16.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "QupaiSDK.h"
#import "QupaiSDK-Private.h"
#import "QPSDKConfig.h"
#import "QPSave.h"
#import "QPBundle.h"
#import "QPImage.h"
#import "QPString.h"
#import "QPProgressHUD.h"

#define RGB(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define RGBToColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define ScreenWidth  CGRectGetWidth([[UIScreen mainScreen] bounds])
#define ScreenHeight CGRectGetHeight([[UIScreen mainScreen] bounds])
#define kQPGreenLineColor RGB(0,204,170)
#define kQPSDKVersion @"1.2.0"

// 趣拍sdk标准版
#define kQPSDK
// 是否打开事件统计功能
#define kQPEnableUploadInfo
// 注释为Release版
//#define kQPEnableDevNetwork


#ifdef kQPEnableDevNetwork
#define kHostUrl @"http://183.129.191.60:8888/duanqu/"
#else
#define kHostUrl @"http://data.qupai.me"
#endif


#ifdef kQPEnableDevNetwork
#define kQPEventHostUrl @"http://192.168.10.210:882/"
#else
#define kQPEventHostUrl @"https://log.qupai.me/"
#endif

#ifdef kQPEnableDevNetwork
#define kQPUploadHostUrl @"http://upload.qupai.me/"
#else
#define kQPUploadHostUrl @"http://up.qupai.me/"
#endif

#ifdef kQPEnableDevNetwork
#define kQPAuthHostUrl @"http://authentication.qupai.me/"
#else
#define kQPAuthHostUrl @"http://auth.qupai.me/"
#endif

#ifdef kQPEnableDevNetwork
#define kQPResourceHostUrl @"http://m.api.inner.qupaicloud.com/"
#else
#define kQPResourceHostUrl @"https://m.api.qupaicloud.com/"
#endif

#ifndef DEBUG
#define NSLog(...)
#endif
