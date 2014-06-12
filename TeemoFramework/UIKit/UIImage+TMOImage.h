//
//  UIImage+TMOImage.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-3-31.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (TMOImage)

/**
*  返回一张纯色的图片，大小为1px*1px
*
*  @param color 指定颜色UIColor对象
*
*  @return 返回UIImage对象
*/
+ (UIImage*)imageWithPureColor:(UIColor*)color;

/**
 *  返回一张被指定颜色覆盖的图片，图片必须为png格式
 *
 *  @param color 指定颜色UIColor对象
 *
 *  @return 处理后的UIImage对象
 */
- (UIImage *)coverWithColor:(UIColor *)color;

@end
