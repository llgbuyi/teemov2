//
//  UIView+TMOSmarty.m
//  TeemoV2
//
//  Created by 崔 明辉 on 14-4-12.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

static NSMutableDictionary *smartyCache;

#import "UIView+TMOSmarty.h"
#import "UIView+TMOView.h"
#import "NSString+TMOString.h"
#import "TMOObjectVerifier.h"
#import "UIImageView+TMOImageView.h"
#import "TMOObjectVerifier.h"


@interface Smarty ()

+ (NSString *)stringByReplaceingSmartyCode:(NSString *)argString
                            withDictionary:(__weak NSDictionary *)argDictionary;
+ (NSAttributedString *)attributedStringByReplaceingSmartyCode:(NSAttributedString *)argString
                                                withDictionary:(__weak NSDictionary *)argDictionary;
+ (NSString *)stringByParam:(NSString *)argParam withDictionary:(__weak NSDictionary *)argDictionary;
+ (BOOL)isSmarty:(NSString *)argString;

@end

@interface Smarty_SystemFunction : NSObject

+ (void)systemFunctionRegister;

@end

@implementation UIView (TMOSmarty)

/**
 *  执行Smarty替换
 */
- (void)smartyRendWithDictionary:(NSDictionary *)argDictionary
                     isRecursive:(BOOL)argIsRecursive {
    [Smarty_SystemFunction systemFunctionRegister];//注册系统默认处理方法
    if ([self.subviews count] == 0) {
        return;
    }
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            [self smartyRendWithLabel:(UILabel *)subView withDictionary:argDictionary];
        }
        else if ([subView isKindOfClass:[UITextField class]]) {
            [self smartyRendWithTextField:(UITextField *)subView withDictionary:argDictionary];
        }
        else if ([subView isKindOfClass:[UITextView class]]) {
            [self smartyRendWithTextView:(UITextView *)subView withDictionary:argDictionary];
        }
        else if ([subView isKindOfClass:[UIButton class]]) {
            [self smartyRendWithButton:(UIButton *)subView withDictionary:argDictionary];
        }
        else if ([subView isKindOfClass:[UIImageView class]]) {
            [self smartyRendWithImageView:(UIImageView *)subView withDictionary:argDictionary];
        }
        //递归渲染
        if (argIsRecursive) {
            [subView smartyRendWithDictionary:argDictionary isRecursive:YES];
        }
    }
}

/**
 *  UILabel
 */
- (void)smartyRendWithLabel:(__weak UILabel *)argLabel
             withDictionary:(__weak NSDictionary *)argDictionary {
    [self saveUIViewOriginData:argLabel];
    if ([[[self valueForOriginData:argLabel theKey:@"attributedText"] string] length] > 0) {
        __weak NSAttributedString *attributedString = [self valueForOriginData:argLabel
                                                                        theKey:@"attributedText"];
        if ([Smarty isSmarty:attributedString.string]) {
            argLabel.attributedText = [Smarty attributedStringByReplaceingSmartyCode:attributedString withDictionary:argDictionary];
        }
    }
    else if ([Smarty isSmarty:[self valueForOriginData:argLabel theKey:@"text"]]) {
        argLabel.text = TOString([Smarty stringByReplaceingSmartyCode:[self valueForOriginData:argLabel theKey:@"text"] withDictionary:argDictionary]);
    }
}

/**
 *  UITextField
 */
- (void)smartyRendWithTextField:(__weak UITextField *)argTextField
                 withDictionary:(__weak NSDictionary *)argDictionary {
    [self saveUIViewOriginData:argTextField];
    if ([Smarty isSmarty:[self valueForOriginData:argTextField theKey:@"placeholder"]]) {
        argTextField.placeholder = TOString([Smarty stringByReplaceingSmartyCode:[self valueForOriginData:argTextField theKey:@"placeholder"] withDictionary:argDictionary]);
    }
    if ([Smarty isSmarty:[self valueForOriginData:argTextField theKey:@"text"]]) {
        argTextField.text = TOString([Smarty stringByReplaceingSmartyCode:[self valueForOriginData:argTextField theKey:@"text"] withDictionary:argDictionary]);
    }
}

/**
 *  UITextView
 */
- (void)smartyRendWithTextView:(__weak UITextView *)argTextView
             withDictionary:(__weak NSDictionary *)argDictionary {
    [self saveUIViewOriginData:argTextView];
    if ([[[self valueForOriginData:argTextView theKey:@"attributedText"] string] length] > 0) {
        __weak NSAttributedString *attributedString = [self valueForOriginData:argTextView
                                                                        theKey:@"attributedText"];
        if ([Smarty isSmarty:attributedString.string]) {
            argTextView.attributedText = [Smarty attributedStringByReplaceingSmartyCode:attributedString withDictionary:argDictionary];
        }
    }
    else {
        if ([Smarty isSmarty:[self valueForOriginData:argTextView theKey:@"text"]]) {
            argTextView.text = TOString([Smarty stringByReplaceingSmartyCode:[self valueForOriginData:argTextView theKey:@"text"]
                                                            withDictionary:argDictionary]);
        }
    }
}

/**
 *  UIButton
 */
- (void)smartyRendWithButton:(__weak UIButton *)argButton
              withDictionary:(__weak NSDictionary *)argDictionary  {
    [self saveUIViewOriginData:argButton];
    if ([Smarty isSmarty:[self valueForOriginData:argButton theKey:@"title"]]) {
        [argButton setTitle:[Smarty stringByReplaceingSmartyCode:[self valueForOriginData:argButton
                                                                                 theKey:@"title"]
                                                withDictionary:argDictionary]
                   forState:UIControlStateNormal];
    }
}

/**
 *  UIImageView
 */
- (void)smartyRendWithImageView:(__weak UIImageView *)argImageView
                 withDictionary:(__weak NSDictionary *)argDictionary {
    [self saveUIViewOriginData:argImageView];
    if ([Smarty isSmarty:[self valueForOriginData:argImageView theKey:@"loadUrl"]]) {
        NSString *loadURLString = [Smarty stringByReplaceingSmartyCode:[self valueForOriginData:argImageView theKey:@"loadUrl"] withDictionary:argDictionary];
        [argImageView loadImageWithURLString:loadURLString];
    }
}

- (void)saveUIViewOriginData:(__weak UIView *)argView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        smartyCache = [NSMutableDictionary dictionary];
    });
    if ([argView valueForAdditionKey:@"smartyOriginDataUniqid"] == nil) {
        
        
        if ([argView isKindOfClass:[UILabel class]]) {
            
            if (![Smarty isSmarty:TOString([(UILabel *)argView text])] &&
                ![Smarty isSmarty:TOString([[(UILabel *)argView attributedText] string])]) {
                return;
            }
            
            NSString *uniqid = [[NSString stringWithFormat:@"%d%d%d",arc4random(), arc4random(), arc4random()] stringByMD5Hash];
            [argView setAdditionValue:uniqid forKey:@"smartyOriginDataUniqid"];
            [smartyCache setObject:@{@"text": TOString([(UILabel *)argView text]),
                                     @"attributedText": [(UILabel *)argView attributedText]
                                     } forKey:uniqid];
        }
        else if ([argView isKindOfClass:[UITextField class]]) {
            
            if (![Smarty isSmarty:[(UITextField *)argView text]] &&
                ![Smarty isSmarty:TOString([(UITextField *)argView placeholder])]) {
                return;
            }
            
            NSString *uniqid = [[NSString stringWithFormat:@"%d%d%d",arc4random(), arc4random(), arc4random()] stringByMD5Hash];
            [argView setAdditionValue:uniqid forKey:@"smartyOriginDataUniqid"];
            [smartyCache setObject:@{@"text": TOString([(UITextField *)argView text]),
                                     @"placeholder": TOString([(UITextField *)argView placeholder])}
                            forKey:uniqid];
        }
        else if ([argView isKindOfClass:[UITextView class]]) {
            
            if (![Smarty isSmarty:[(UITextView *)argView text]] &&
                ![Smarty isSmarty:TOString([[(UITextView *)argView attributedText] string])]) {
                return;
            }
            
            NSString *uniqid = [[NSString stringWithFormat:@"%d%d%d",arc4random(), arc4random(), arc4random()] stringByMD5Hash];
            [argView setAdditionValue:uniqid forKey:@"smartyOriginDataUniqid"];
            [smartyCache setObject:@{@"text": TOString([(UITextView *)argView text]),
                                     @"attributedText":[(UITextView *)argView attributedText]}
                            forKey:uniqid];
        }
        else if ([argView isKindOfClass:[UIButton class]]) {
            
            if (![Smarty isSmarty:[(UIButton *)argView titleForState:UIControlStateNormal]]) {
                return;
            }
            
            NSString *uniqid = [[NSString stringWithFormat:@"%d%d%d",arc4random(), arc4random(), arc4random()] stringByMD5Hash];
            [argView setAdditionValue:uniqid forKey:@"smartyOriginDataUniqid"];
            [smartyCache setObject:@{@"title": [(UIButton *)argView titleForState:UIControlStateNormal]}
                            forKey:uniqid];
        }
        else if ([argView isKindOfClass:[UIImageView class]]) {
            
            if (![Smarty isSmarty:TOString(argView.accessibilityLabel)]) {
                return;
            }
            
            NSString *uniqid = [[NSString stringWithFormat:@"%d%d%d",arc4random(), arc4random(), arc4random()] stringByMD5Hash];
            [argView setAdditionValue:uniqid forKey:@"smartyOriginDataUniqid"];
            [smartyCache setObject:@{@"loadUrl": TOString(argView.accessibilityLabel)}
                            forKey:uniqid];
        }
    }
}

- (id)valueForOriginData:(__weak UIView *)argView theKey:(NSString *)argTheKey{
    if ([argView valueForAdditionKey:@"smartyOriginDataUniqid"] != nil) {
        if (smartyCache[[argView valueForAdditionKey:@"smartyOriginDataUniqid"]] != nil) {
            return smartyCache[[argView valueForAdditionKey:@"smartyOriginDataUniqid"]][argTheKey];
        }
    }
    return nil;
}

@end



/**
 *  Smarty
 */

static NSMutableDictionary *smartyCustomFunction;

@implementation Smarty

/**
 *  注册一个Smarty自定义函数
 *
 *  @param argName  函数标识符
 *  @param argOwner 函数执行者
 */
+ (void)functionRegisterWithName:(NSString *)argName
                       withOwner:(id)argOwner
                    withSelector:(SEL)argSelector{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        smartyCustomFunction = [NSMutableDictionary dictionary];
    });
    [smartyCustomFunction setObject:@{@"owner": argOwner,
                                      @"selector": [NSValue valueWithPointer:argSelector]}
                             forKey:argName];
}

/**
 *  若传入argName则注销一个Smarty自定义函数
 *  若传入argOwner则注销owner下的所有Smarty自定义函数
 *  若argName和argOwner均为空，则注销所有Smarty自定义函数
 *
 *  @param argName  函数名
 *  @param argOwner 函数执行者
 */
+ (void)functionUnregisterWithName:(NSString *)argName owner:(id)argOwner{
    if (argName == nil && argOwner == nil) {
        [smartyCustomFunction removeAllObjects];
    }
    else if (argName != nil) {
        [smartyCustomFunction removeObjectForKey:argName];
    }
    else if (argOwner != nil) {
        for (NSString *key in smartyCustomFunction) {
            if (smartyCustomFunction[key][@"owner"] == argOwner) {
                [smartyCustomFunction removeObjectForKey:key];
            }
        }
    }
}

+ (NSString *)executeFunctionWithName:(NSString *)argName
                            withValue:(NSString *)argValue
                           withParams:(NSArray *)argParams{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *returnString = @"";
    if (smartyCustomFunction[argName] != nil) {
        id owner = smartyCustomFunction[argName][@"owner"];
        SEL selector = [smartyCustomFunction[argName][@"selector"] pointerValue];
        if ([owner respondsToSelector:selector]) {
            returnString = [owner performSelector:selector
                                       withObject:@{@"value": argValue, @"params": argParams}];
        }
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

+ (NSRegularExpression *)matchingRegularExpression {
    static NSRegularExpression *regularExpression;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regularExpression = [[NSRegularExpression alloc] initWithPattern:@"<\\{\\$([^\\}]+)\\}>"
                                                                 options:NSRegularExpressionAllowCommentsAndWhitespace
                                                                   error:nil];
    });
    return regularExpression;
}

/**
 *  替换所有Smarty关键词至最终值
 */
+ (NSString *)stringByReplaceingSmartyCode:(NSString *)argString
                            withDictionary:(__weak NSDictionary *)argDictionary {
    NSString *newString = [argString copy];
    __weak NSRegularExpression *regularExpression = [Smarty matchingRegularExpression];
    NSArray *theResult = [regularExpression matchesInString:argString
                                                    options:NSMatchingReportCompletion
                                                      range:NSMakeRange(0, [argString length])];
    for (NSTextCheckingResult *resultItem in theResult) {
        if (resultItem.numberOfRanges >= 2) {
            NSString *smartyString = [argString substringWithRange:[resultItem rangeAtIndex:0]];
            NSString *smartyParam = [argString substringWithRange:[resultItem rangeAtIndex:1]];
            newString = [newString stringByReplacingOccurrencesOfString:smartyString
                                                             withString:[self stringByParam:smartyParam
                                                                             withDictionary:argDictionary]];
        }
    }
    return newString;
}

/**
 *  替换AttributedString关键词至最终值
 *
 *  @param argString     NSAttributedString
 *  @param argDictionary NSDictionary
 *
 *  @return NSAttributedString
 */
+ (NSAttributedString *)attributedStringByReplaceingSmartyCode:(NSAttributedString *)argString
                                                withDictionary:(__weak NSDictionary *)argDictionary {
    NSMutableAttributedString *mutableAttributedString = [argString mutableCopy];
    for (;[Smarty isSmarty:mutableAttributedString.string];) {
        __weak NSRegularExpression *regularExpression = [Smarty matchingRegularExpression];
        NSArray *theResult = [regularExpression matchesInString:mutableAttributedString.string
                                                        options:NSMatchingReportCompletion
                                                          range:NSMakeRange(0, [mutableAttributedString.string length])];
        for (NSTextCheckingResult *resultItem in theResult) {
            if (resultItem.numberOfRanges >= 2) {
                NSString *smartyParam = [mutableAttributedString.string substringWithRange:[resultItem rangeAtIndex:1]];
                [mutableAttributedString replaceCharactersInRange:resultItem.range withString:[Smarty stringByParam:smartyParam withDictionary:argDictionary]];
            }
            break;
        }
    }
    return [mutableAttributedString copy];
}

/**
 *  取得最终值
 */
+ (NSString *)stringByParam:(NSString *)argParam withDictionary:(__weak NSDictionary *)argDictionary {
    
    NSArray *functionUseArray;
    if ([argParam contains:@"|"]) {
        //注册函数调用
        functionUseArray = [argParam componentsSeparatedByString:@"|"];
        argParam = [functionUseArray firstObject];
    }
    
    id lastValue = argDictionary;
    NSArray *theResult = [argParam componentsSeparatedByString:@"["];
    NSUInteger index = 0;
    for (NSString *resultItem in theResult) {
        NSString *theKey = [resultItem stringByReplacingOccurrencesOfString:@"]" withString:@""];
        if ([theKey contains:@"'"] || [theKey contains:@"\""] || index == 0) {
            //可认为是字典取值
            theKey = [theKey stringByReplacingOccurrencesOfString:@"'" withString:@""];
            theKey = [theKey stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if ([lastValue isKindOfClass:[NSDictionary class]]) {
                lastValue = [lastValue valueForKey:TOString(theKey)];
            }
            else {
                return @"";
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


@implementation Smarty_SystemFunction

+ (void)systemFunctionRegister {
    static Smarty_SystemFunction *systemFunction;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemFunction = [[Smarty_SystemFunction alloc] init];
        [Smarty functionRegisterWithName:@"replace" withOwner:systemFunction withSelector:@selector(replace:)];
        [Smarty functionRegisterWithName:@"length" withOwner:systemFunction withSelector:@selector(length:)];
        [Smarty functionRegisterWithName:@"dateFormat" withOwner:systemFunction withSelector:@selector(dateFormat:)];
        [Smarty functionRegisterWithName:@"dateOffset" withOwner:systemFunction withSelector:@selector(dateOffset:)];
        [Smarty functionRegisterWithName:@"floatFormat" withOwner:systemFunction withSelector:@selector(floatFormat:)];
        [Smarty functionRegisterWithName:@"default" withOwner:systemFunction withSelector:@selector(theDefault:)];
        [Smarty functionRegisterWithName:@"truncate" withOwner:systemFunction withSelector:@selector(truncate:)];
    });
}

/**
 *  替换字符
 *  Smarty用法：$result|replace:待替换字符:替换字符
 *
 *  @param object 信息
 *
 *  @return 替换完毕的字符信息
 */
- (NSString *)replace:(NSDictionary *)object {
    if (ISValidArray(object[@"params"], 2)) {
        return TOString([object[@"value"] stringByReplacingOccurrencesOfString:TOString(object[@"params"][1])
                                                                    withString:TOString(object[@"params"][2])]);
    }
    else{
        return TOString(object[@"value"]);
    }
}

/**
 *  计算字符串长度
 *  Smarty用法：$result|length
 *
 *  @param object 信息
 *
 *  @return 字符串长度(NSString)
 */
- (NSString *)length:(NSDictionary *)object {
    return [NSString stringWithFormat:@"%lu", (unsigned long)[TOString(object[@"value"]) length]];
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
- (NSString *)dateFormat:(NSDictionary *)object {
    NSMutableArray *dateFormatArray = [object[@"params"] mutableCopy];
    [dateFormatArray removeObjectAtIndex:0];
    NSString *dateFormatString = [dateFormatArray componentsJoinedByString:@":"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:TOInteger(object[@"value"])];
    
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
- (NSString *)dateOffset:(NSDictionary *)object {
    NSDate *date = [NSDate date];
    if (date.timeIntervalSince1970 - TOInteger(object[@"value"]) < 60) {
        return @"刚刚";
    }
    else if (date.timeIntervalSince1970 - TOInteger(object[@"value"]) < 3600){
        return [NSString stringWithFormat:@"%d分钟前", (int)(TOInteger(object[@"value"]) - date.timeIntervalSince1970)/60];
    }
    else if (date.timeIntervalSince1970 - TOInteger(object[@"value"]) < 43200) {
        return [NSString stringWithFormat:@"%d小时前", (int)(TOInteger(object[@"value"]) - date.timeIntervalSince1970)/3600];
    }
    else{
        return [self dateFormat:object];
    }
}

/**
 *  将字符串转换为浮点数，并以指定的浮点数显示形式返回
 *  示例  <{$value|floatFormat:%d}> 这将返回一个整型
 *
 *  @param object object
 *
 *  @return NSString
 */
- (NSString *)floatFormat:(NSDictionary *)object {
    if (ISValidArray(object[@"params"], 1)) {
        return [NSString stringWithFormat:object[@"params"][1], TOFloat(object[@"value"])];
    }
    return TOString(object[@"value"]);
}

/**
 *  当Value为空时，显示一个默认的字符串
 *  调用示例   <{$result|default:加载失败}>
 *
 *  @param object obejct
 *
 *  @return NSString
 */
- (NSString *)theDefault:(NSDictionary *)object {
    if ([TOString(object[@"value"]) length] > 0) {
        return TOString(object[@"value"]);
    }
    if (ISValidArray(object[@"params"], 1)) {
        return TOString(object[@"params"][1]);
    }
    else {
        return @"";
    }
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
- (NSString *)truncate:(NSDictionary *)object {
    NSInteger length = ISValidArray(object[@"params"], 1) ? TOInteger(object[@"params"][1]) : 80;
    NSString *etc = ISValidArray(object[@"params"], 2) ? TOString(object[@"params"][2]) : @"...";
    BOOL middle = ISValidArray(object[@"params"], 3) ? [TONumber(object[@"params"][3]) boolValue] : NO;
    
    if (length == 0) {
        return @"";
    }
    
    if ([TOString(object[@"value"]) length] > 0) {
        length -= MIN(length, [etc length]);
        if (!middle) {
            return [[TOString(object[@"value"]) substringWithRange:NSMakeRange(0, length)] stringByAppendingString:etc];
        }
        return [NSString stringWithFormat:@"%@%@%@",
                [TOString(object[@"value"]) substringWithRange:NSMakeRange(0, length/2)],
                etc,
                [TOString(object[@"value"]) substringWithRange:NSMakeRange([TOString(object[@"value"]) length]-length/2, length/2)]];
    }
    
    return TOString(object[@"value"]);
}

@end