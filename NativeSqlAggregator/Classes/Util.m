//
//  Util.m
//  SalesForceMarvels
//
//  Created by Vishnu Sharma on 7/17/15.
//  Copyright (c) 2015 salesforce. All rights reserved.
//

#import "Util.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Util

+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

+ (id) getValueFor:(NSString *) key inJSON:(NSDictionary *) dict
{
    return ([dict objectForKey:key]!= (id)[NSNull null])? [dict objectForKey:key]:@"";
}

@end
