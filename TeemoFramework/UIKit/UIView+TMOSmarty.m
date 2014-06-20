//
//  UIView+TMOSmarty.m
//  TeemoV2
//
//  Created by 崔 明辉 on 14-4-12.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

static NSMutableDictionary *smartyDictionary;
static NSRegularExpression *smartyRegularExpression;

#import "UIView+TMOSmarty.h"
#import "UIView+TMOView.h"
#import "NSString+TMOString.h"
#import "TMOObjectVerifier.h"
#import "UIImageView+TMOImageView.h"
#import "TMOObjectVerifier.h"
#import "TMOToolKitMacro.h"

@interface Smarty ()

+ (void)instance;

+ (NSString *)stringByReplaceingSmartyCode:(NSString *)argString
                            withDictionary:(NSDictionary *)argDictionary;
+ (NSAttributedString *)attributedStringByReplaceingSmartyCode:(NSAttributedString *)argString
                                                withDictionary:(NSDictionary *)argDictionary;
+ (NSString *)stringByParam:(NSString *)argParam withDictionary:(NSDictionary *)argDictionary;
+ (BOOL)isSmarty:(NSString *)argString;

@end

@interface SmartySystemFunction : NSObject

+ (void)instance;

@end

@implementation UIView (TMOSmarty)

/**
 *  执行Smarty替换
 */
- (void)smartyRendWithDictionary:(NSDictionary *)argDictionary
                     isRecursive:(BOOL)argIsRecursive {
    [Smarty instance];
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
- (void)smartyRendWithLabel:(UILabel *)argLabel
             withDictionary:(NSDictionary *)argDictionary {
    [self saveOriginData:argLabel];
    //优先处理attributedString
    if ([argLabel valueForAdditionKey:@"smartyAttributedText"] != nil) {
        NSAttributedString *attributedString = [argLabel valueForAdditionKey:@"smartyAttributedText"];
        argLabel.attributedText = [Smarty attributedStringByReplaceingSmartyCode:attributedString
                                                                  withDictionary:argDictionary];
    }
    else if ([argLabel valueForAdditionKey:@"smartyText"] != nil) {
        argLabel.text = [Smarty stringByReplaceingSmartyCode:[argLabel valueForAdditionKey:@"smartyText"]
                                              withDictionary:argDictionary];
    }
}

/**
 *  UITextField
 */
- (void)smartyRendWithTextField:(UITextField *)argTextField
                 withDictionary:(NSDictionary *)argDictionary {
    [self saveOriginData:argTextField];
    if ([argTextField valueForAdditionKey:@"smartyPlaceholder"] != nil) {
        argTextField.placeholder = [Smarty stringByReplaceingSmartyCode:[argTextField valueForAdditionKey:@"smartyPlaceholder"]
                                                         withDictionary:argDictionary];
    }
    if ([argTextField valueForAdditionKey:@"smartyText"] != nil) {
        argTextField.text = [Smarty stringByReplaceingSmartyCode:[argTextField valueForAdditionKey:@"smartyText"]
                                                  withDictionary:argDictionary];
    }
}

/**
 *  UITextView
 */
- (void)smartyRendWithTextView:(UITextView *)argTextView
             withDictionary:(NSDictionary *)argDictionary {
    [self saveOriginData:argTextView];
    //优先处理attributedString
    if ([argTextView valueForAdditionKey:@"smartyAttributedText"] != nil) {
        NSAttributedString *attributedString = [argTextView valueForAdditionKey:@"smartyAttributedText"];
        argTextView.attributedText = [Smarty attributedStringByReplaceingSmartyCode:attributedString
                                                                     withDictionary:argDictionary];
    }
    else if ([argTextView valueForAdditionKey:@"smartyText"] != nil) {
        argTextView.text = [Smarty stringByReplaceingSmartyCode:[argTextView valueForAdditionKey:@"smartyText"]
                                                 withDictionary:argDictionary];
    }
}

/**
 *  UIButton
 */
- (void)smartyRendWithButton:(UIButton *)argButton
              withDictionary:(NSDictionary *)argDictionary  {
    [self saveOriginData:argButton];
    if ([argButton valueForAdditionKey:@"smartyTitle"] != nil) {
        [argButton setTitle:[Smarty stringByReplaceingSmartyCode:[argButton valueForAdditionKey:@"smartyTitle"]
                                                  withDictionary:argDictionary]
                   forState:UIControlStateNormal];
    }
}

/**
 *  UIImageView
 */
- (void)smartyRendWithImageView:(UIImageView *)argImageView
                 withDictionary:(NSDictionary *)argDictionary {
    [self saveOriginData:argImageView];
    if ([argImageView valueForAdditionKey:@"smartyImageURLString"] != nil) {
        NSString *loadURLString = [Smarty stringByReplaceingSmartyCode:[argImageView valueForAdditionKey:@"smartyImageURLString"]
                                                        withDictionary:argDictionary];
        [argImageView loadImageWithURLString:loadURLString];
    }
}

- (void)saveOriginData:(UIView *)argView {
    if ([argView isKindOfClass:[UILabel class]]) {
        if ([Smarty isSmarty:TOString([(UILabel *)argView text])]) {
            [argView setAdditionValue:[(UILabel *)argView text] forKey:@"smartyText"];
        }
        if (TMO_SYSTEM_VERSION >= 6.0 &&
            [Smarty isSmarty:TOString([[(UILabel *)argView attributedText] string])]) {
            [argView setAdditionValue:[(UILabel *)argView attributedText] forKey:@"smartyAttributedText"];
        }
    }
    else if ([argView isKindOfClass:[UITextField class]]) {
        if ([Smarty isSmarty:TOString([(UITextField *)argView text])]) {
            [argView setAdditionValue:[(UITextField *)argView text] forKey:@"smartyText"];
        }
        if ([Smarty isSmarty:TOString([(UITextField *)argView placeholder])]) {
            [argView setAdditionValue:[(UITextField *)argView placeholder] forKey:@"smartyPlaceholder"];
        }
    }
    else if ([argView isKindOfClass:[UITextView class]]) {
        if ([Smarty isSmarty:TOString([(UITextView *)argView text])]) {
            [argView setAdditionValue:[(UITextView *)argView text] forKey:@"smartyText"];
        }
        if (TMO_SYSTEM_VERSION >= 6.0 &&
            [Smarty isSmarty:TOString([[(UITextView *)argView attributedText] string])]) {
            [argView setAdditionValue:[(UITextView *)argView attributedText] forKey:@"smartyAttributedText"];
        }
    }
    else if ([argView isKindOfClass:[UIButton class]]) {
        if ([Smarty isSmarty:TOString([(UIButton *)argView titleForState:UIControlStateNormal])]) {
            [argView setAdditionValue:[(UIButton *)argView titleForState:UIControlStateNormal] forKey:@"smartyTitle"];
        }
    }
    else if ([argView isKindOfClass:[UIImageView class]]) {
        if ([Smarty isSmarty:TOString(argView.accessibilityLabel)]) {
            [argView setAdditionValue:argView.accessibilityIdentifier forKey:@"smartyImageURLString"];
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
                            withDictionary:(NSDictionary *)argDictionary {
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
                                                withDictionary:(NSDictionary *)argDictionary {
    NSMutableAttributedString *mutableAttributedString = [argString mutableCopy];
    for (;[Smarty isSmarty:mutableAttributedString.string];) {
        NSArray *theResult = [smartyRegularExpression matchesInString:mutableAttributedString.string
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
+ (NSString *)stringByParam:(NSString *)argParam withDictionary:(NSDictionary *)argDictionary {
    
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