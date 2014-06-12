//
//  UIButton+TMOButton.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-10.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (TMOButton)

/**
 *  覆盖一个imageView在UIButton上
 *  并执行回调
 *
 *  @param argCallback 回调
 */
- (void)setCustomImageView:(void(^)(UIImageView *imageView))argCallback;

/**
 *  加载指定URL的图片，将设置到UIButton的指定状态中
 *
 *  @param argControlState     状态
 *  @param argURLString        URL
 *  @param argPlaceHolderImage 加载成功前的图片
 */
- (void)setCustomImageForState:(UIControlState)argControlState
                 withURLString:(NSString *)argURLString
          withPlaceHolderImage:(UIImage *)argPlaceHolderImage;

@end
