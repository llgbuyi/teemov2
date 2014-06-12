//
//  TMOColor.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-3-31.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (TMOColor)

/**
 *  将16进制色值转换为UIColor对象
 *
 *  @param argHexString 例#333333
 *
 *  @return UIColor对象
 */
+ (UIColor *)colorWithHex:(NSString *)argHexString;

/**
 *  将数字形式表示的RGB转换为UIColor，而无须自行除于255.0
 *
 *  @param red   R
 *  @param green G
 *  @param blue  B
 *  @param alpha A
 *
 *  @return UIColor对象
 */
+ (UIColor *)colorWithRedUseInteger:(NSInteger)red
                              green:(NSInteger)green
                               blue:(NSInteger)blue
                              alpha:(CGFloat)alpha;

@end
