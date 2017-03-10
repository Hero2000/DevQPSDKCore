//
//  QPAuth-Private.h
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 16/4/13.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "QPAuth.h"

typedef NS_ENUM(NSInteger, QPLicenseValidationType) {
    QPLicenseValidationTypeUnkonwn = 0,
    QPLicenseValidationTypeSuccess = 200,
    QPLicenseValidationTypeOverdue = 101,
    QPLicenseValidationTypeInvalid = 102,
    QPLicenseValidationTypeNetworkUnreachable = 1024,
};

@interface QPAuth() <NSURLSessionDataDelegate>
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, copy) NSString *space;

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, assign) NSInteger expire;
@property (nonatomic, strong) NSDictionary *errorInfo;
@end
