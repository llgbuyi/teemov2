//
//  UIView+TMOSmarty.h
//  TeemoV2
//
//  Created by 崔 明辉 on 14-4-12.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Smarty : NSObject

/**
 *  注册一个Smarty自定义函数
 *
 *  @param argName  函数标识符
 *  @param argOwner 函数执行者
 */
+ (void)functionRegisterWithName:(NSString *)argName
                       withOwner:(id)argOwner
                    withSelector:(SEL)argSelector;

/**
 *  若传入argName则注销一个Smarty自定义函数
 *  若传入argOwner则注销owner下的所有Smarty自定义函数
 *  若argName和argOwner均为空，则注销所有Smarty自定义函数
 *
 *  @param argName  函数名
 *  @param argOwner 函数执行者
 */
+ (void)functionUnregisterWithName:(NSString *)argName owner:(id)argOwner;

@end

@interface UIView (TMOSmarty)

/**
 *  对当前View下的所有SubView执行Smarty替换
 *
 *  @param argDictionary 数据字典
 *  @param argIsRecursive 是否递归执行，即view.subview.subview.subview.....均会被执行替换
 */
- (void)smartyRendWithDictionary:(NSDictionary *)argDictionary
                     isRecursive:(BOOL)argIsRecursive ;

@end