//
//  TMOColor.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-3-31.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "UIColor+TMOColor.h"

@implementation UIColor (TMOColor)

+ (UIColor *)colorWithHex:(NSString *)argHexString{
    NSAssert(argHexString != nil, @"HexString不能传入空值");
    NSString *hexString = [argHexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSAssert(hexString.length == 6, @"HexString长度不能少于6");
    CGFloat red = strtoul([[hexString substringWithRange:NSMakeRange(0, 2)] UTF8String], 0, 16);
    CGFloat green = strtoul([[hexString substringWithRange:NSMakeRange(2, 2)] UTF8String], 0, 16);
    CGFloat blue = strtoul([[hexString substringWithRange:NSMakeRange(4, 2)] UTF8String], 0, 16);
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

+ (UIColor *)colorWithRedUseInteger:(NSInteger)red
                              green:(NSInteger)green
                               blue:(NSInteger)blue
                              alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:(float)red/255.0
                           green:(float)green/255.0
                            blue:(float)blue/255.0
                           alpha:alpha];
}

@end
