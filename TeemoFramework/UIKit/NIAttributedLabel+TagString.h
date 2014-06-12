//
//  NIAttributedLabel+TagString.h
//  BasicInstantiation
//
//  Created by 崔明辉 on 14-6-5.
//  Copyright (c) 2014年 NimbusKit. All rights reserved.
//

#import "NIAttributedLabel.h"

/**
 *  HTML标签的结构
 */
@interface TTTagItem : NSObject

/**
 *  当前标签的名称
 *  如：<hello id=1>kitty</hello>
 *  则此值为hello
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  当前标签的参数值
 *  如：<hello id=1>kitty</hello>
 *  则此值为 id => 1
 */
@property (nonatomic, readonly) NSDictionary *params;

/**
 *  当前标签在整个字符串中的range
 */
@property (assign, readonly) NSRange range;

/**
 *  生成一个标签结构体
 *
 *  @param argName   标签名称
 *  @param argParams 标签属性
 *  @param argRange  标签Range
 *
 *  @return TTTagItem
 */
- (id)initWithName:(NSString *)argName withParams:(NSDictionary *)argParams withRange:(NSRange)argRange;

@end

/**
 *  标签处理回调
 *
 *  @param tagItem   标签结构
 *  @param theString 完整的可变AttributedString字符串
 */
typedef void (^TTTagBlock)(TTTagItem *tagItem, NSMutableAttributedString *theString);

/**
 *  NIAttributedLabel扩展
 */
@interface NIAttributedLabel (TagString)

/**
 *  使用TagString扩展前，必须执行此instance
 */
+ (void)instance;

/**
 *  使用tagString为NIAttributedLabel渲染文本
 *
 *  @param argTagString 标签文本
 *
 *  @return 返回处理好的attributedString，可以用于后续的计算操作
 */
- (NSAttributedString *)setWithTagString:(NSString *)argTagString;

/**
 *  为NIAttributedLabel添加所有既定的链接
 *  使用link标签后，不要忘记使用此方法，否则，所有的链接都不会被加上
 *  使用NIAttributedLabelDelegate进行链接的点击事件回调
 */
- (void)addLinks;

/**
 *  为NIAttributedLabel添加所有既定的ImageView
 *  使用image标签后，不要忘记使用此方法，否则，所有的ImageView都不会被加上
 */
- (void)addImages;

/**
 *  直接返回处理好的tagString标签文本
 *
 *  @param argTagString 标签文本
 *
 *  @return 返回处理好的attributedString，可以用于后续的计算操作、处理操作、渲染操作
 */
+ (NSMutableAttributedString *)attributedStringWithTagString:(NSString *)argTagString;

/**
 *  为指定标签定义处理方法
 *
 *  @param argBlock   处理回调块
 *  @param argTagName 指定标签
 */
+ (void)addStyleBlock:(TTTagBlock)argBlock tagName:(NSString *)argTagName;

/**
 *  为指定标签定义样式
 *
 *  @param argAttributed 指定样式，使用标准的attributes，例：NSFontAttributeName
 *  @param argTagName    指定的标签名称
 */
+ (void)addStyleAttributed:(NSDictionary *)argAttributed tagName:(NSString *)argTagName;

/**
 *  移除某个标签的处理方法
 *
 *  @param argTagName 标签名称
 */
+ (void)removeStyleForTagName:(NSString *)argTagName;

/**
 *  移除所有标签的处理方法，包括系统内置标签
 */
+ (void)removeAllStyle;

@end

@interface NSMutableAttributedString (TTTagString)

/**
 *  为NSMutableAttributedString设置最小行高
 *  这适用于为iOS6+ UILabel设置最小行距
 *
 *  @param lineHeight 最小行高
 */
- (void)nimbuskit_setMinimumLineHeight:(CGFloat)lineHeight;

/**
 *  为NSMutableAttributedString设置最小行高
 *  这适用于为iOS6+ UILabel设置最小行距
 
 *  @param lineHeight 最小行高
 *  @param range      指定range
 */
- (void)nimbuskit_setMinimumLineHeight:(CGFloat)lineHeight
                                 range:(NSRange)range;

@end
