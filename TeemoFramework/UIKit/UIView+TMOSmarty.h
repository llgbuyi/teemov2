//
//  UIView+TMOSmarty.h
//  TeemoV2
//
//  Created by 崔 明辉 on 14-4-12.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString *(^SmartyCallbackBlock)(NSString *theString, NSArray *theParams);

@interface Smarty : NSObject

+ (void)addFunction:(SmartyCallbackBlock)argBlock withTagName:(NSString *)tagName;

+ (void)removeFunctionWithTagName:(NSString *)tagName;

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