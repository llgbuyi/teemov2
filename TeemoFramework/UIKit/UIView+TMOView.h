//
//  UIView+TMOView.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-1.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>

@interface UIView (TMOView)

/**
 *  清除所有此UIView下的所有subview
 */
- (void)removeAllSubviews;

/**
 *  在view中居中呈现一个菊花浮框指示器
 *  你可以使用MBProgressHUD的自定义方法，呈现更多效果
 *
 *  @return MBProgressHUD对象
 */
- (MBProgressHUD *)showHUD;

/**
 *  在view中居中呈现一个菊花+文字加载中的指示器
 *  一直呈现，除非执行hideHUD
 */
- (MBProgressHUD *)showHUDWithLoadingView;

/**
 *  在view中居中呈现一个文字浮框指示器，并在指定秒数后自动消失
 *
 *  @param argText        显示的文字
 *  @param argHideDelayed N秒后消失
 */
- (MBProgressHUD *)showHUDWithText:(NSString *)argText
            hideDelayed:(NSTimeInterval)argHideDelayed;


/**
 *  隐藏当前view中的所有指示器
 */
- (void)hideHUD;

/**
 *  根据Class查找subview中的指定view
 *
 *  @param argClass Class
 *
 *  @return UIView/nil
 */
- (UIView *)subviewWithClass:(Class)argClass;

/**
 *  根据Class查找subview中的指定view
 *
 *  @param argClass       Class
 *  @param argIsRecursive 是否递归查找，若是，则将一直递归查找所有层级的View
 *
 *  @return UIView/nil
 */
- (UIView *)subviewWithClass:(Class)argClass isRecursive:(BOOL)argIsRecursive;

/**
 *  根据TagId查找subview中的指定view
 *
 *  @param argTagId tagId
 *
 *  @return UIView/nil
 */
- (UIView *)subviewWithTagId:(NSInteger)argTagId;

/**
 *  根据TagId查找subview中的指定view
 *
 *  @param argTagId       tagId
 *  @param argIsRecursive 是否递归查找，若是，则将一直递归查找所有层级的View
 *
 *  @return UIView/nil
 */
- (UIView *)subviewWithTagId:(NSInteger)argTagId isRecursive:(BOOL)argIsRecursive;


/**
 *  为UIView自定义Key-Value
 *
 *  @param argValue Value
 *  @param argKey   Key
 */
- (void)setAdditionValue:(id)argValue forKey:(NSString *)argKey;

/**
 *  取得已经自定义好的Key-Value
 *
 *  @param argKey key
 *
 *  @return Object
 */
- (id)valueForAdditionKey:(NSString *)argKey;

/**
 *  在view的右上角展现一个数字圆角标
 *
 *  @param argInteger 角标数字，为0则隐藏角标
 */
- (void)showBadge:(NSInteger)argInteger;

@end
