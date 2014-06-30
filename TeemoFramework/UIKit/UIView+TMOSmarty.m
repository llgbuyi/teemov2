//
//  UIView+TMOSmarty.m
//  TeemoV2
//
//  Created by 崔 明辉 on 14-4-12.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

static NSMutableDictionary *smartyDictionary;
static NSRegularExpression *smartyRegularExpression;

#import "TMOToolKitCore.h"
#import "UIView+TMOSmarty.h"
#import "UIView+TMOView.h"
#import "UIImageView+TMOImageView.h"


@interface Smarty ()

+ (void)instance;

+ (NSString *)stringByReplaceingSmartyCode:(NSString *)argString
                            withObject:(NSDictionary *)argObject;
+ (NSAttributedString *)attributedStringByReplaceingSmartyCode:(NSAttributedString *)argString
                                                withObject:(NSDictionary *)argObject;
+ (NSString *)stringByParam:(NSString *)argParam withObject:(NSDictionary *)argObject;
+ (BOOL)isSmarty:(NSString *)argString;

+ (void)addSmartyBindBySmartyCode:(NSString *)argString
                         withView:(UIView *)argView
                   withDataSource:(id)argDataSource;

@end

@interface SmartySystemFunction : NSObject

+ (void)instance;

@end

@interface SmartyBinder : NSObject

@property (nonatomic, assign) SmartyBindCallbackBlock callback;
@property (nonatomic, copy) NSString *bindKey;
@property (nonatomic, weak) UIView *bindView;
@property (nonatomic, weak) id bindObject;
@property (nonatomic, weak) id dataSource;

- (instancetype)initWithBindObject:(id)argBindObject
                    withDataSource:(id)argDataSource
                          withView:(UIView *)argView
                           withKey:(NSString *)argKey;

@end

@implementation UIView (TMOSmarty)

/**
 *  执行Smarty替换
 */
- (void)smartyRendWithDictionary:(NSDictionary *)argDictionary isRecursive:(BOOL)argIsRecursive {
    [self smartyRendWithObject:argDictionary isRecursive:argIsRecursive];
}

- (void)smartyRendWithObject:(id)argObject isRecursive:(BOOL)argIsRecursive {
    [Smarty instance];
    //self
    [self smartyReplaceWithObject:argObject];
    if (argIsRecursive) {
        for (UIView *subView in self.subviews) {
            [subView smartyRendWithObject:argObject isRecursive:YES];
        }
    }
}

/**
 *  SmartyBind
 *  Model View动态绑定
 */

- (void)smartyBind {
    [self setAdditionValue:@(YES) forKey:@"smartyBinded"];
}

- (void)smartyBindForSubviews {
    [self setAdditionValue:@(YES) forKey:@"smartyBinded"];
    [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj smartyBindForSubviews];
    }];
}

- (void)smartyBindWithBlock:(SmartyBindCallbackBlock)argBlock {
    [self setAdditionValue:@(YES) forKey:@"smartyBinded"];
    [self setAdditionValue:argBlock forKey:@"smartyBindCallbackBlock"];
}

- (void)smartyUnBind {
    [self removeAdditionValueForKey:@"smartyBinded"];
    [self removeAdditionValueForKey:@"smartyBinder"];
    [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj smartyUnBind];
    }];
}

- (void)smartyReplaceWithObject:(id)argObject {
    [self smartySaveOriginData:argObject];
    if ([self valueForAdditionKey:@"smartyAttributedText"] != nil) {
        NSAttributedString *attributedString = [self valueForAdditionKey:@"smartyAttributedText"];
        [(UILabel *)self setAttributedText:[Smarty attributedStringByReplaceingSmartyCode:attributedString
                                                                               withObject:argObject]];
    }
    else if ([self valueForAdditionKey:@"smartyText"] != nil) {
        NSString *text = [self valueForAdditionKey:@"smartyText"];
        [(UILabel *)self setText:[Smarty stringByReplaceingSmartyCode:text withObject:argObject]];
    }
    if ([self valueForAdditionKey:@"smartyPlaceholder"] != nil) {
        NSString *text = [self valueForAdditionKey:@"smartyPlaceholder"];
        [(UITextField *)self setPlaceholder:[Smarty stringByReplaceingSmartyCode:text withObject:argObject]];
    }
    if ([self valueForAdditionKey:@"smartyTitle"] != nil) {
        NSString *text = [self valueForAdditionKey:@"smartyTitle"];
        [(UIButton *)self setTitle:[Smarty stringByReplaceingSmartyCode:text withObject:argObject]
                          forState:UIControlStateNormal];
    }
    if ([self valueForAdditionKey:@"smartyImageURLString"] != nil) {
        NSString *text = [self valueForAdditionKey:@"smartyImageURLString"];
        [(UIImageView *)self loadImageWithURLString:[Smarty stringByReplaceingSmartyCode:text withObject:argObject]];
    }
}

- (void)smartySaveOriginData:(id)argDataSource {
    if ([self isKindOfClass:[UILabel class]]) {
        if ([Smarty isSmarty:TOString([(UILabel *)self text])]) {
            [self setAdditionValue:[(UILabel *)self text] forKey:@"smartyText"];
            [Smarty addSmartyBindBySmartyCode:[(UILabel *)self text] withView:self withDataSource:argDataSource];
        }
        if (TMO_SYSTEM_VERSION >= 6.0 &&
            [Smarty isSmarty:TOString([[(UILabel *)self attributedText] string])]) {
            [self setAdditionValue:[(UILabel *)self attributedText] forKey:@"smartyAttributedText"];
            [Smarty addSmartyBindBySmartyCode:[[(UILabel *)self attributedText] string] withView:self withDataSource:argDataSource];
        }
    }
    else if ([self isKindOfClass:[UITextField class]]) {
        if ([Smarty isSmarty:TOString([(UITextField *)self text])]) {
            [self setAdditionValue:[(UITextField *)self text] forKey:@"smartyText"];
            [Smarty addSmartyBindBySmartyCode:[(UITextField *)self text] withView:self withDataSource:argDataSource];
        }
        if ([Smarty isSmarty:TOString([(UITextField *)self placeholder])]) {
            [self setAdditionValue:[(UITextField *)self placeholder] forKey:@"smartyPlaceholder"];
            [Smarty addSmartyBindBySmartyCode:[(UITextField *)self placeholder] withView:self withDataSource:argDataSource];
        }
    }
    else if ([self isKindOfClass:[UITextView class]]) {
        if ([Smarty isSmarty:TOString([(UITextView *)self text])]) {
            [self setAdditionValue:[(UITextView *)self text] forKey:@"smartyText"];
            [Smarty addSmartyBindBySmartyCode:[(UITextView *)self text] withView:self withDataSource:argDataSource];
        }
        if (TMO_SYSTEM_VERSION >= 6.0 &&
            [Smarty isSmarty:TOString([[(UITextView *)self attributedText] string])]) {
            [self setAdditionValue:[(UITextView *)self attributedText] forKey:@"smartyAttributedText"];
            [Smarty addSmartyBindBySmartyCode:[[(UITextView *)self attributedText] string] withView:self withDataSource:argDataSource];
        }
    }
    else if ([self isKindOfClass:[UIButton class]]) {
        if ([Smarty isSmarty:TOString([(UIButton *)self titleForState:UIControlStateNormal])]) {
            [self setAdditionValue:[(UIButton *)self titleForState:UIControlStateNormal] forKey:@"smartyTitle"];
            [Smarty addSmartyBindBySmartyCode:[(UIButton *)self titleForState:UIControlStateNormal] withView:self withDataSource:argDataSource];
        }
    }
    else if ([self isKindOfClass:[UIImageView class]]) {
        if ([Smarty isSmarty:TOString(self.accessibilityLabel)]) {
            [self setAdditionValue:self.accessibilityIdentifier forKey:@"smartyImageURLString"];
            [Smarty addSmartyBindBySmartyCode:[(UIImageView *)self accessibilityIdentifier] withView:self withDataSource:argDataSource];
        }
    }
}

@end

/**
 *  Smarty
 */

@implementation Smarty

+ (void)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        smartyDictionary = [NSMutableDictionary dictionary];
        smartyRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"<\\{\\$([^\\}]+)\\}>"
                                                                       options:NSRegularExpressionAllowCommentsAndWhitespace
                                                                         error:nil];
        [SmartySystemFunction instance];
    });
}

+ (void)addFunction:(SmartyCallbackBlock)argBlock withTagName:(NSString *)tagName {
    if (smartyDictionary != nil) {
        [smartyDictionary setObject:argBlock forKey:tagName];
    }
}

+ (void)removeFunctionWithTagName:(NSString *)tagName {
    if (smartyDictionary != nil) {
        [smartyDictionary removeObjectForKey:tagName];
    }
}

+ (SmartyCallbackBlock)blockForTagName:(NSString *)tagName {
    return smartyDictionary[tagName];
}

+ (NSString *)executeFunctionWithName:(NSString *)argName
                            withValue:(NSString *)argValue
                           withParams:(NSArray *)argParams{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *returnString = @"";
    SmartyCallbackBlock block = [self blockForTagName:argName];
    if (block != nil) {
        returnString = block(argValue, argParams);
    }
    else {
        returnString = argValue;
    }
    return returnString;
#pragma clang diagnostic pop
}

+ (NSString *)leftDelimiter {
    static NSString *leftDelimiter = @"<{";
    return leftDelimiter;
}

+ (NSString *)rightDelimiter {
    static NSString *rightDelimiter = @"}>";
    return rightDelimiter;
}

/**
 *  替换所有Smarty关键词至最终值
 */
+ (NSString *)stringByReplaceingSmartyCode:(NSString *)argString
                            withObject:(NSDictionary *)argObject {
    NSString *newString = [argString copy];
    NSArray *theResult = [smartyRegularExpression matchesInString:argString
                                                          options:NSMatchingReportCompletion
                                                            range:NSMakeRange(0, [argString length])];
    for (NSTextCheckingResult *resultItem in theResult) {
        if (resultItem.numberOfRanges >= 2) {
            NSString *smartyString = [argString substringWithRange:[resultItem rangeAtIndex:0]];
            NSString *smartyParam = [argString substringWithRange:[resultItem rangeAtIndex:1]];
            newString = [newString stringByReplacingOccurrencesOfString:smartyString
                                                             withString:[self stringByParam:smartyParam
                                                                             withObject:argObject]];
        }
    }
    return newString;
}

+ (void)addSmartyBindBySmartyCode:(NSString *)argString
                         withView:(UIView *)argView
                   withDataSource:(id)argDataSource {
    if ([argView valueForAdditionKey:@"smartyBinded"] != nil) {
        NSArray *theResult = [smartyRegularExpression matchesInString:argString
                                                              options:NSMatchingReportCompletion
                                                                range:NSMakeRange(0, [argString length])];
        for (NSTextCheckingResult *resultItem in theResult) {
            if (resultItem.numberOfRanges >= 2) {
                NSString *argParam = [argString substringWithRange:[resultItem rangeAtIndex:1]];
                {
                    NSArray *functionUseArray;
                    if ([argParam contains:@"|"]) {
                        //注册函数调用
                        functionUseArray = [argParam componentsSeparatedByString:@"|"];
                        argParam = [functionUseArray firstObject];
                    }
                    
                    id lastValue = argDataSource;
                    id targetObject = argDataSource;
                    NSString *targetKey;
                    NSArray *theResult = [argParam componentsSeparatedByString:@"["];
                    NSUInteger index = 0;
                    for (NSString *resultItem in theResult) {
                        NSString *theKey = [resultItem stringByReplacingOccurrencesOfString:@"]" withString:@""];
                        if ([theKey contains:@"'"] || [theKey contains:@"\""] || index == 0) {
                            theKey = [theKey stringByReplacingOccurrencesOfString:@"'" withString:@""];
                            theKey = [theKey stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                            targetKey = theKey;
                            SEL sel = sel_registerName([theKey cStringUsingEncoding:NSUTF8StringEncoding]);
                            if ([lastValue respondsToSelector:sel]) {
                                //可认为是对象取值
                                targetObject = lastValue;
                                lastValue = [lastValue performSelector:sel withObject:nil];
                                if (lastValue == nil) {
                                    targetObject = nil;
                                    break;
                                }
                            }
                            else {
                                //可认为是字典取值
                                if ([lastValue isKindOfClass:[NSDictionary class]]) {
                                    targetObject = lastValue;
                                    lastValue = [lastValue valueForKey:TOString(theKey)];
                                }
                                else {
                                    targetObject = nil;
                                    break;
                                }
                            }
                        }
                        else {
                            //可认为是数组取值
                            if (ISValidArray(lastValue, TOInteger(theKey))) {
                                targetObject = lastValue;
                                lastValue = [lastValue objectAtIndex:TOInteger(theKey)];
                            }
                            else{
                                targetObject = nil;
                                break;
                            }
                        }
                        index++;
                    }
                    if (targetObject != nil) {
                        [argView setAdditionValue:[[SmartyBinder alloc] initWithBindObject:targetObject
                                                                            withDataSource:argDataSource
                                                                                  withView:argView
                                                                                   withKey:targetKey]
                                           forKey:@"smartyBinder"];
                    }
                }
                
            }
        }
    }
}

/**
 *  替换AttributedString关键词至最终值
 *
 *  @param argString     NSAttributedString
 *  @param argObject NSDictionary
 *
 *  @return NSAttributedString
 */
+ (NSAttributedString *)attributedStringByReplaceingSmartyCode:(NSAttributedString *)argString
                                                withObject:(NSDictionary *)argObject {
    NSMutableAttributedString *mutableAttributedString = [argString mutableCopy];
    for (;[Smarty isSmarty:mutableAttributedString.string];) {
        NSArray *theResult = [smartyRegularExpression matchesInString:mutableAttributedString.string
                                                              options:NSMatchingReportCompletion
                                                                range:NSMakeRange(0, [mutableAttributedString.string length])];
        for (NSTextCheckingResult *resultItem in theResult) {
            if (resultItem.numberOfRanges >= 2) {
                NSString *smartyParam = [mutableAttributedString.string substringWithRange:[resultItem rangeAtIndex:1]];
                [mutableAttributedString replaceCharactersInRange:resultItem.range withString:[Smarty stringByParam:smartyParam withObject:argObject]];
            }
            break;
        }
    }
    return [mutableAttributedString copy];
}

/**
 *  取得最终值
 */
+ (NSString *)stringByParam:(NSString *)argParam withObject:(id)argObject {
    
    NSArray *functionUseArray;
    if ([argParam contains:@"|"]) {
        //注册函数调用
        functionUseArray = [argParam componentsSeparatedByString:@"|"];
        argParam = [functionUseArray firstObject];
    }
    
    id lastValue = argObject;
    NSArray *theResult = [argParam componentsSeparatedByString:@"["];
    NSUInteger index = 0;
    for (NSString *resultItem in theResult) {
        NSString *theKey = [resultItem stringByReplacingOccurrencesOfString:@"]" withString:@""];
        if ([theKey contains:@"'"] || [theKey contains:@"\""] || index == 0) {
            theKey = [theKey stringByReplacingOccurrencesOfString:@"'" withString:@""];
            theKey = [theKey stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            SEL sel = sel_registerName([theKey cStringUsingEncoding:NSUTF8StringEncoding]);
            if ([lastValue respondsToSelector:sel]) {
                //可认为是对象取值
                lastValue = [lastValue performSelector:sel withObject:nil];
                if (lastValue == nil) {
                    return @"";
                }
            }
            else {
                //可认为是字典取值
                if ([lastValue isKindOfClass:[NSDictionary class]]) {
                    lastValue = [lastValue valueForKey:TOString(theKey)];
                }
                else {
                    return @"";
                }
            }
        }
        else {
            //可认为是数组取值
            if (ISValidArray(lastValue, TOInteger(theKey))) {
                lastValue = [lastValue objectAtIndex:TOInteger(theKey)];
            }
            else{
                return @"";
            }
        }
        index++;
    }
    
    if (functionUseArray != nil) {
        for (NSUInteger i=1; i<[functionUseArray count]; i++) {
            NSArray *components = [functionUseArray[i] componentsSeparatedByString:@":"];
            NSString *functionName = [components firstObject];
            lastValue = [self executeFunctionWithName:functionName
                                            withValue:TOString(lastValue)
                                           withParams:components];
        }
    }
    
    return TOString(lastValue);
}

/**
 *  检测是否包含Smarty关键词
 */
+ (BOOL)isSmarty:(NSString *)argString {
    if ([argString contains:[self leftDelimiter]] && [argString contains:[self rightDelimiter]]) {
        return YES;
    }
    else {
        return NO;
    }
}

@end


@implementation SmartySystemFunction

+ (void)instance {
    [self replace];
    [self length];
    [self dateFormat];
    [self dateOffset];
    [self truncate];
    [self floatFormat];
    [self theDefault];
}

/**
 *  替换字符
 *  Smarty用法：$result|replace:待替换字符:替换字符
 *
 *  @param object 信息
 *
 *  @return 替换完毕的字符信息
 */
+ (void)replace {
    [Smarty addFunction:^NSString *(NSString *theString, NSArray *theParams) {
        if (ISValidArray(theParams, 2)) {
            return [TOString(theString) stringByReplacingOccurrencesOfString:TOString(theParams[1])
                                                                  withString:TOString(theParams[2])];
        }
        else{
            return TOString(theString);
        }
    } withTagName:@"replace"];
}

/**
 *  计算字符串长度
 *  Smarty用法：$result|length
 *
 *  @param object 信息
 *
 *  @return 字符串长度(NSString)
 */
+ (void)length {
    [Smarty addFunction:^NSString *(NSString *theString, NSArray *theParams) {
        return [NSString stringWithFormat:@"%lu", (unsigned long)[TOString(theString) length]];
    } withTagName:@"length"];
    
}

/**
 *  将时间戳转换为指定格式
 *  Value必须为Unix标准时间戳，即由1970年1月1日0时0分0秒起计算的秒数差
 *  示例： <{$result|dateFormat:%Y-%m-%d %H:%i:%s}>
 *
 *  @param object 信息
 *
 *  @return 指定格式字符串
 */
+ (void)dateFormat {
    [Smarty addFunction:^NSString *(NSString *theString, NSArray *theParams) {
        NSMutableArray *dateFormatArray = [theParams mutableCopy];
        [dateFormatArray removeObjectAtIndex:0];
        NSString *dateFormatString = [dateFormatArray componentsJoinedByString:@":"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:TOInteger(theString)];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
        NSDateComponents *components = [calendar components:unitFlags fromDate:date];
        
        
        dateFormatString = [dateFormatString stringByReplacingOccurrencesOfString:@"%Y"
                                                                       withString:[NSString stringWithFormat:@"%ld", (long)components.year]];
        dateFormatString = [dateFormatString stringByReplacingOccurrencesOfString:@"%y"
                                                                       withString:[[NSString stringWithFormat:@"%ld", (long)components.year] substringFromIndex:2]];
        
        dateFormatString = [dateFormatString stringByReplacingOccurrencesOfString:@"%m"
                                                                       withString:[NSString stringWithFormat:@"%02ld", (long)components.month]];
        
        dateFormatString = [dateFormatString stringByReplacingOccurrencesOfString:@"%d"
                                                                       withString:[NSString stringWithFormat:@"%02ld", (long)components.day]];
        
        dateFormatString = [dateFormatString stringByReplacingOccurrencesOfString:@"%H"
                                                                       withString:[NSString stringWithFormat:@"%02ld", (long)components.hour]];
        
        dateFormatString = [dateFormatString stringByReplacingOccurrencesOfString:@"%i"
                                                                       withString:[NSString stringWithFormat:@"%02ld", (long)components.minute]];
        
        dateFormatString = [dateFormatString stringByReplacingOccurrencesOfString:@"%s"
                                                                       withString:[NSString stringWithFormat:@"%02ld", (long)components.second]];
        
        dateFormatString = [dateFormatString stringByReplacingOccurrencesOfString:@"%w"
                                                                       withString:[NSString stringWithFormat:@"%ld", (long)components.weekday-1]];
        
        return dateFormatString;
    } withTagName:@"dateFormat"];
}

/**
 *  返回时间差形式的字符串
 *  Value必须为Unix时间戳
 *  必须提供后备参数
 *  示例  <{$value|dateOffset:%Y年%m月%d日}>
 *
 *  @param object object
 *
 *  @return NSString
 */
+ (void)dateOffset {
    [Smarty addFunction:^NSString *(NSString *theString, NSArray *theParams) {
        NSDate *date = [NSDate date];
        if (date.timeIntervalSince1970 - TOInteger(theString) < 60) {
            return @"刚刚";
        }
        else if (date.timeIntervalSince1970 - TOInteger(theString) < 3600){
            return [NSString stringWithFormat:@"%d分钟前", (int)(TOInteger(theString) - date.timeIntervalSince1970)/60];
        }
        else if (date.timeIntervalSince1970 - TOInteger(theString) < 43200) {
            return [NSString stringWithFormat:@"%d小时前", (int)(TOInteger(theString) - date.timeIntervalSince1970)/3600];
        }
        else{
            SmartyCallbackBlock dateFormatBlock = smartyDictionary[@"dateFormat"];
            if (dateFormatBlock != nil) {
                return dateFormatBlock(theString, theParams);
            }
            else {
                return @"";
            }
        }
    } withTagName:@"dateOffset"];
}

/**
 *  将字符串转换为浮点数，并以指定的浮点数显示形式返回
 *  示例  <{$value|floatFormat:%d}> 这将返回一个整型
 *
 *  @param object object
 *
 *  @return NSString
 */
+ (void)floatFormat {
    [Smarty addFunction:^NSString *(NSString *theString, NSArray *theParams) {
        if (ISValidArray(theParams, 1)) {
            return [NSString stringWithFormat:theParams[1], TOFloat(theString)];
        }
        return TOString(theString);
    } withTagName:@"floatFormat"];
}

/**
 *  当Value为空时，显示一个默认的字符串
 *  调用示例   <{$result|default:加载失败}>
 *
 *  @param object obejct
 *
 *  @return NSString
 */
+ (void)theDefault {
    
    [Smarty addFunction:^NSString *(NSString *theString, NSArray *theParams) {
        if ([TOString(theString) length] > 0) {
            return theString;
        }
        if (ISValidArray(theParams, 1)) {
            return TOString(theParams[1]);
        }
        else {
            return @"";
        }
    } withTagName:@"default"];
}

/**
 *  截取字符串到指定长度
 *  所有参数都是可选的
 *  第一个参数：截取的长度  默认80
 *  第二个参数：截取后替代显示的字符，该字符长度会被计算到截取长度内，默认为 ...
 *  第三个参数：中段截取，1为是0为否，若是，则将截取后的字符串会是  “呵呵呵呵呵呵...呵呵呵呵呵呵” 这个样子
 *
 *  @param object object
 *
 *  @return NSString
 */
+ (void)truncate {
    [Smarty addFunction:^NSString *(NSString *theString, NSArray *theParams) {
        NSInteger length = ISValidArray(theParams, 1) ? TOInteger(theParams[1]) : 80;
        NSString *etc = ISValidArray(theParams, 2) ? TOString(theParams[2]) : @"...";
        BOOL middle = ISValidArray(theParams, 3) ? [TONumber(theParams[3]) boolValue] : NO;
        if (length == 0) {
            return @"";
        }
        if ([TOString(theString) length] > 0) {
            length -= MIN(length, [etc length]);
            if (!middle) {
                return [[TOString(theString) substringWithRange:NSMakeRange(0, length)] stringByAppendingString:etc];
            }
            return [NSString stringWithFormat:@"%@%@%@",
                    [TOString(theString) substringWithRange:NSMakeRange(0, length/2)],
                    etc,
                    [TOString(theString) substringWithRange:NSMakeRange([TOString(theString) length]-length/2, length/2)]];
        }
        return TOString(theString);
    } withTagName:@"truncate"];
}

@end

@implementation SmartyBinder

- (void)dealloc {
    [self.bindObject removeObserver:self forKeyPath:self.bindKey context:nil];
}

- (instancetype)initWithBindObject:(id)argBindObject
                    withDataSource:(id)argDataSource
                          withView:(UIView *)argView
                           withKey:(NSString *)argKey {
    self = [super init];
    if (self) {
        self.bindObject = argBindObject;
        self.dataSource = argDataSource;
        self.bindView = argView;
        self.bindKey = argKey;
        [self.bindObject addObserver:self
                          forKeyPath:self.bindKey
                             options:NSKeyValueObservingOptionNew
                             context:nil];
        self.callback = [self.bindView valueForAdditionKey:@"smartyBindCallbackBlock"];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.bindView smartyRendWithObject:self.dataSource isRecursive:NO];
    if (self.callback != nil) {
        self.callback(self.bindView, self.dataSource, self.bindObject, keyPath, change[NSKeyValueChangeNewKey]);
    }
}

@end