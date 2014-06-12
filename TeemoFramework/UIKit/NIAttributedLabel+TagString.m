//
//  NIAttributedLabel+TagString.m
//  BasicInstantiation
//
//  Created by 崔明辉 on 14-6-5.
//  Copyright (c) 2014年 NimbusKit. All rights reserved.
//

static NSMutableDictionary *styleDictionary;

#import "NIAttributedLabel+TagString.h"
#import "TMOToolKitCore.h"
#import "TMOUIKitCore.h"

NSString *stringWithoutTags(NSString *argText) {
    NSString *withoutTagsString = [argText stringByReplacingOccurrencesOfString:@"<.*?>"
                                                                     withString:@""
                                                                        options:NSRegularExpressionSearch
                                                                          range:NSMakeRange(0, argText.length)];
    return withoutTagsString;
}

@interface TTTagParser : NSObject

@property (nonatomic, readonly) NSArray *tags;

- (id)initWithTagString:(NSString *)argTagString;

@end

@interface TTTagExtension : NSObject

+ (void)instance;

@end

@implementation NIAttributedLabel (TagString)

+ (void)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        styleDictionary = [NSMutableDictionary dictionary];
        [TTTagExtension instance];
    });
}

- (void)setWithTagString:(NSString *)argTagString {
    [self setAttributedText:[[NIAttributedLabel attributedStringWithTagString:argTagString] copy]];
}

- (void)addLinks {
    NSAttributedString *attributedString = self.attributedText;
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.string.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs[NSLinkAttributeName] != nil &&
            [attrs[NSLinkAttributeName] isKindOfClass:[NSString class]]) {
            [self addLink:[NSURL URLWithString:attrs[NSLinkAttributeName]] range:range];
        }
    }];
}

- (void)addImages {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAttributedString *attributedString = self.attributedText;
        [attributedString enumerateAttributesInRange:NSMakeRange(0, [attributedString.string length]) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            if (attrs[@"TTTagName"] != nil && [attrs[@"TTTagName"] isEqualToString:@"image"]) {
                //Calculate offset
                CGFloat width = attrs[@"TTTagParams"] != nil && attrs[@"TTTagParams"][@"width"] != nil ? [attrs[@"TTTagParams"][@"width"] floatValue] : 0.0;
                CGFloat height = attrs[@"TTTagParams"] != nil && attrs[@"TTTagParams"][@"height"] != nil ? [attrs[@"TTTagParams"][@"height"] floatValue] : 0.0;
                CGFloat x = [self lastLineWidthWithAttributedString:[attributedString attributedSubstringFromRange:NSMakeRange(0, range.location)]];
                NSString *previousLetter = range.location > 0 ? [[attributedString string] substringWithRange:NSMakeRange(range.location-1, 1)] : @"";
                if (x + width > self.frame.size.width || [previousLetter isEqualToString:@"\n"]) {
                    x = 0.0;
                }
                CGFloat y = NISizeOfAttributedStringConstrainedToSize([attributedString attributedSubstringFromRange:NSMakeRange(0, range.location+range.length)], CGSizeMake(self.frame.size.width, CGFLOAT_MAX), 0).height - height;
                
                CGFloat xOffset = attrs[@"TTTagParams"] != nil && attrs[@"TTTagParams"][@"left"] != nil ? [attrs[@"TTTagParams"][@"left"] floatValue] : 0.0;
                CGFloat yOffset = attrs[@"TTTagParams"] != nil && attrs[@"TTTagParams"][@"bottom"] != nil ? [attrs[@"TTTagParams"][@"bottom"] floatValue] : 0.0;
                x += xOffset;
                y -= yOffset;
                
                CGRect rect = CGRectMake(x, y, width, height);
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
                imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addSubview:imageView];
                });
                //Load Image{
                if (![TOString(attrs[@"TTTagParams"][@"src"]) isBlank]) {
                    if ([TOString(attrs[@"TTTagParams"][@"src"]) rangeOfString:@"http://"].location == 0) {
                        //Network
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imageView loadImageWithURLString:TOString(attrs[@"TTTagParams"][@"src"])];
                        });
                    }
                    else {
                        //Local
                        UIImage *image = [UIImage imageNamed:TOString(attrs[@"TTTagParams"][@"src"])];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.image = image;
                        });
                    }
                }
                //}Load Image
            }
        }];
    });
}

- (CGFloat)lastLineWidthWithAttributedString:(NSAttributedString *)argAttributedString {
    CGFloat x;
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)argAttributedString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, self.frame.size.width, CGFLOAT_MAX));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CFRetain(frame);
    NSArray *lines = (NSArray *)CFBridgingRelease(CTFrameGetLines(frame));
    
    CTLineRef lineRef = (__bridge  CTLineRef)[lines lastObject];
    CFRange lineRange = CTLineGetStringRange(lineRef);
    NSRange lineNSRange = NSMakeRange(lineRange.location, lineRange.length);
    NSAttributedString *lineAttributedString = [argAttributedString attributedSubstringFromRange:lineNSRange];
    CGFloat lastLineWidth = NISizeOfAttributedStringConstrainedToSize(lineAttributedString, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), 0).width;
    CFRelease(frame);
    CGPathRelease(path);
    CFRelease(frameSetter);
    x = lastLineWidth;
    return x;
}

+ (NSMutableAttributedString *)attributedStringWithTagString:(NSString *)argTagString {
    TTTagParser *tagParser = [[TTTagParser alloc] initWithTagString:argTagString];
    NSMutableAttributedString *mutableAttributedString = [[[NSAttributedString alloc] initWithString:stringWithoutTags(argTagString)] mutableCopy];
    
    //default{
    if (styleDictionary[@"$default"] != nil) {
        if ([styleDictionary[@"$default"] isKindOfClass:[NSDictionary class]]) {
            [mutableAttributedString addAttributes:styleDictionary[@"$default"] range:NSMakeRange(0, [[mutableAttributedString string] length])];
        }
        else {
            TTTagItem *defaultTagItem = [[TTTagItem alloc] initWithName:@"$default" withParams:nil withRange:NSMakeRange(0, [[mutableAttributedString string] length])];
            TTTagBlock block = styleDictionary[@"$default"];
            block(defaultTagItem, mutableAttributedString);
        }
    }
    //}default
    
    [tagParser.tags enumerateObjectsUsingBlock:^(TTTagItem *obj, NSUInteger idx, BOOL *stop) {
        if (styleDictionary[obj.name] != nil) {
            if ([styleDictionary[obj.name] isKindOfClass:[NSDictionary class]]) {
                [mutableAttributedString addAttributes:styleDictionary[obj.name] range:obj.range];
            }
            else {
                TTTagBlock block = styleDictionary[obj.name];
                block(obj, mutableAttributedString);
            }
            //plusHook{
            //使用tagName+的方式执行更多操作，如image，则使用image+标记即可执行后续操作
            NSString *plusName = [NSString stringWithFormat:@"%@+",obj.name];
            if (styleDictionary[plusName] != nil) {
                if ([styleDictionary[plusName] isKindOfClass:[NSDictionary class]]) {
                    [mutableAttributedString addAttributes:styleDictionary[plusName] range:obj.range];
                }
                else {
                    TTTagBlock block = styleDictionary[plusName];
                    block(obj, mutableAttributedString);
                }
            }
            //}plusHook
        }
        
    }];
    return mutableAttributedString;
}

+ (void)addStyleBlock:(TTTagBlock)argBlock tagName:(NSString *)argTagName {
    [styleDictionary setObject:argBlock forKey:argTagName];
}

+ (void)addStyleAttributed:(NSDictionary *)argAttributed tagName:(NSString *)argTagName {
    [styleDictionary setObject:argAttributed forKey:argTagName];
}

+ (void)removeStyleForTagName:(NSString *)argTagName {
    [styleDictionary removeObjectForKey:argTagName];
}

+ (void)removeAllStyle {
    [styleDictionary removeAllObjects];
}

@end


@implementation TTTagParser

- (id)initWithTagString:(NSString *)argTagString {
    self = [super init];
    if (self) {
        [self parse:argTagString];
    }
    return self;
}

- (void)parse:(NSString *)argTagString {
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSMutableString *theText = [argTagString mutableCopy];
    NSArray *tags = [self allTagsWithTagString:argTagString];
    
    for (NSString *tagItem in tags) {
        NSRegularExpression *tagItemRegularExpression =
        [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"(<%@.*?>)(.*?)(</%@>)", tagItem, tagItem]
                                             options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                               error:nil];
        NSTextCheckingResult *firstMatch = [tagItemRegularExpression firstMatchInString:theText
                                                                                options:NSMatchingReportCompletion
                                                                                  range:NSMakeRange(0, [theText length])];
        
        if (firstMatch.numberOfRanges > 0) {
            
            NSUInteger matchLocation = 0;
            NSUInteger matchLength = 0;
            
            matchLocation = firstMatch.range.location;
            matchLength = [stringWithoutTags([theText substringWithRange:firstMatch.range]) length];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            NSString *paramString = [theText substringWithRange:[firstMatch rangeAtIndex:1]];
            paramString = [paramString substringToIndex:[paramString length]-1];
            NSArray *paramComponents = [paramString componentsSeparatedByString:@" "];
            for (NSUInteger i=1; i<[paramComponents count]; i++) {
                NSString *paramItemString = paramComponents[i];
                NSArray *paramItemArray = [paramItemString componentsSeparatedByString:@"="];
                if ([paramItemArray count] == 2) {
                    [params setObject:[paramItemArray lastObject]
                               forKey:[paramItemArray firstObject]];
                }
            }
            
            TTTagItem *tttagItem = [[TTTagItem alloc] initWithName:tagItem
                                                        withParams:[params copy]
                                                         withRange:NSMakeRange(matchLocation, matchLength)];
            
            [resultArray addObject:tttagItem];
            [theText replaceCharactersInRange:[firstMatch rangeAtIndex:3] withString:@""];
            [theText replaceCharactersInRange:[firstMatch rangeAtIndex:1] withString:@""];
        }
    }
    _tags = [resultArray copy];
}

- (NSArray *)allTagsWithTagString:(NSString *)argTagString {
    NSMutableArray *tagArray = [NSMutableArray array];
    NSRegularExpression *tagsRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"<([a-zA-Z0-9]+).*?>"
                                                                                      options:NSRegularExpressionCaseInsensitive
                                                                                        error:nil];
    NSArray *matches = [tagsRegularExpression matchesInString:argTagString
                                                      options:NSMatchingReportCompletion
                                                        range:NSMakeRange(0, [argTagString length])];
    for (NSTextCheckingResult *matchItem in matches) {
        if (matchItem.numberOfRanges >= 2) {
            [tagArray addObject:[argTagString substringWithRange:[matchItem rangeAtIndex:1]]];
        }
    }
    return [tagArray copy];
}

@end

@implementation TTTagItem

- (id)initWithName:(NSString *)argName withParams:(NSDictionary *)argParams withRange:(NSRange)argRange {
    self = [super init];
    if (self) {
        _name = argName;
        _params = argParams;
        _range = argRange;
    }
    return self;
}

@end

CGFloat TTTSpaceDelegateGetAscentCallback(void* refCon) {
    NSDictionary *dictionary = (__bridge NSDictionary *)refCon;
    CGFloat height = 0.0;
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return 0.0;
    }
    if (dictionary[@"height"] != nil) {
        height = [dictionary[@"height"] floatValue];
        return height;
    }
    return 0.0;
}

CGFloat TTTSpaceDelegateGetDescentCallback(void* refCon) {
    return 0.0;
}

CGFloat TTTSpaceDelegateGetWidthCallback(void* refCon) {
    NSDictionary *dictionary = (__bridge NSDictionary *)refCon;
    CGFloat width = 0.0;
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return 0.0;
    }
    if (dictionary[@"width"] != nil) {
        width = [dictionary[@"width"] floatValue];
        return width;
    }
    return 0.0;
}

void TTTRunDelegateDeallocCalllback(void *refCon) {
    CFRelease(refCon);
}

@implementation TTTagExtension

+ (void)instance {
    [TTTagExtension link];
    [TTTagExtension image];
    [TTTagExtension space];
}

+ (void)link {
    [NIAttributedLabel addStyleBlock:^(TTTagItem *tagItem, NSMutableAttributedString *theString) {
        if ([tagItem.params[@"href"] isKindOfClass:[NSString class]]) {
            [theString addAttributes:@{NSLinkAttributeName: tagItem.params[@"href"]}
                               range:tagItem.range];
        }
    } tagName:@"link"];
}

+ (void)image {
    [NIAttributedLabel addStyleBlock:^(TTTagItem *tagItem, NSMutableAttributedString *theString) {
        
        CGFloat width = tagItem.params[@"width"] != nil ? [tagItem.params[@"width"] floatValue] : 0.0;
        if (tagItem.params[@"left"] != nil) {
            width += [tagItem.params[@"left"] floatValue];
        }
        if (tagItem.params[@"right"] != nil) {
            width += [tagItem.params[@"right"] floatValue];
        }
        
        CGFloat height = tagItem.params[@"height"] != nil ? [tagItem.params[@"height"] floatValue] : 0.0;
        if (tagItem.params[@"top"] != nil) {
            height += [tagItem.params[@"top"] floatValue];
        }
        if (tagItem.params[@"bottom"] != nil) {
            height += [tagItem.params[@"bottom"] floatValue];
        }
        
        NSAttributedString *spaceString = [self spaceAttributedString:width
                                                           withHeight:height];
        if (spaceString != nil) {
            [theString replaceCharactersInRange:tagItem.range withAttributedString:spaceString];
            [theString addAttributes:@{@"TTTagName": @"image",
                                       @"TTTagParams": tagItem.params}
                               range:tagItem.range];
        }
    } tagName:@"image"];
}

+ (void)space {
    [NIAttributedLabel addStyleBlock:^(TTTagItem *tagItem, NSMutableAttributedString *theString) {
        NSAttributedString *spaceString = [self spaceAttributedString:[tagItem.params[@"width"] floatValue] withHeight:[tagItem.params[@"height"] floatValue]];
        if (spaceString != nil) {
            [theString replaceCharactersInRange:tagItem.range withAttributedString:spaceString];
        }
    } tagName:@"space"];
}

+ (NSAttributedString *)spaceAttributedString:(CGFloat)width withHeight:(CGFloat)height {
    CTRunDelegateCallbacks spaceCallbacks;
    memset(&spaceCallbacks, 0, sizeof(CTRunDelegateCallbacks));
    spaceCallbacks.version = kCTRunDelegateVersion1;
    spaceCallbacks.dealloc = TTTRunDelegateDeallocCalllback;
    spaceCallbacks.getAscent = TTTSpaceDelegateGetAscentCallback;
    spaceCallbacks.getDescent = TTTSpaceDelegateGetDescentCallback;
    spaceCallbacks.getWidth = TTTSpaceDelegateGetWidthCallback;
    NSDictionary *sizeParams = [[NSDictionary alloc] initWithObjectsAndKeys:@(height), @"height", @(width), @"width", nil];
    void *sizeParamsCT = (__bridge void *)sizeParams;
    CFRetain(sizeParamsCT);
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&spaceCallbacks, sizeParamsCT);
    if (runDelegate != NULL) {
        NSMutableAttributedString *spaceAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];
        [spaceAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName
                                      value:(__bridge id)runDelegate
                                      range:NSMakeRange(0, 1)];
        CFRelease(runDelegate);
        return spaceAttributedString;
    }
    return nil;
}

@end

@implementation NSMutableAttributedString (TTTagString)

- (void)nimbuskit_setMinimumLineHeight:(CGFloat)lineHeight {
    [self nimbuskit_setMinimumLineHeight:lineHeight range:NSMakeRange(0, [[self string] length])];
}

- (void)nimbuskit_setMinimumLineHeight:(CGFloat)lineHeight
                                 range:(NSRange)range {
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    [self addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

@end

