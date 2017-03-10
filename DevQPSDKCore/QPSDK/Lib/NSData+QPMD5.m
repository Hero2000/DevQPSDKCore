//
//  NSData+QPMD5.m
//  ALBBQuPaiPlugin
//
//  Created by zhangwx on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "NSData+QPMD5.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSData (QPMD5)
- (NSString*)md5 {
    const char *cStr = [self bytes];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)self.length, result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end
