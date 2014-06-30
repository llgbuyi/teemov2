//
//  UIView+TMOView.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-1.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#define kTMOBadgeViewTag -10001

#import "UIView+TMOView.h"
#import "NSString+TMOString.h"
#import "UIView+TMOSmarty.h"
#import <objc/runtime.h>

@interface TMOProgressHUD : MBProgressHUD

@end

@implementation TMOProgressHUD

+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    TMOProgressHUD *hud = [super showHUDAddedTo:view animated:animated];
    if (![view isKindOfClass:[UIWindow class]]) {
        [hud setYOffset:-32];
        UIView *checkTextField = [view subviewWithClass:[UITextField class] isRecursive:YES];
        UIView *checkTextView = [view subviewWithClass:[UITextView class] isRecursive:YES];
        if (checkTextField != nil || checkTextView != nil) {
            //添加键盘事件监控
            [[NSNotificationCenter defaultCenter] addObserver:hud
                                                     selector:@selector(keyboardWillShow)
                                                         name:UIKeyboardWillShowNotification
                                                       object:nil];
        }
    }
    return hud;
}

- (void)hide:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [super hide:animated];
}

- (void)keyboardWillShow {
    if ([[self superview] isKindOfClass:[UIWindow class]]) {
        return;
    }
    [self setYOffset:0];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

@end

static char kUIViewAddtionValueKey;

@interface UIView (TMOViewAddtional)

@property (strong, nonatomic) NSMutableDictionary *additionValueDictionary;

@end

@implementation UIView (TMOViewAddtional)

@dynamic additionValueDictionary;

- (NSMutableDictionary *)additionValueDictionary {
    return (NSMutableDictionary *)objc_getAssociatedObject(self, &kUIViewAddtionValueKey);
}

- (void)setAdditionValueDictionary:(NSMutableDictionary *)additionValueDictionary {
    objc_setAssociatedObject(self, &kUIViewAddtionValueKey, additionValueDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIView (TMOView)

#pragma mark -
#pragma mark - HUD

- (MBProgressHUD *)showHUD {
    if ([[[UIApplication sharedApplication] windows] count] > 1) {
        return [TMOProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] windows] objectAtIndex:1] animated:YES];
    }
    return [TMOProgressHUD showHUDAddedTo:self animated:YES];
}

- (MBProgressHUD *)showHUDWithLoadingView {
    MBProgressHUD *hud = [self showHUD];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud setLabelText:@"加载中..."];
    return hud;
}

- (MBProgressHUD *)showHUDWithText:(NSString *)argText
                       hideDelayed:(NSTimeInterval)argHideDelayed {
    if (argText == nil) {
        return nil;
    }
    MBProgressHUD *hud = [self showHUD];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:argText];
    if (argHideDelayed > 0) {
        [hud hide:YES afterDelay:argHideDelayed];
    }
    return hud;
}

- (void)hideHUD {
    [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [MBProgressHUD hideAllHUDsForView:obj animated:YES];
    }];
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
}

- (UIView *)subviewWithClass:(Class)argClass {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:argClass]) {
            return subView;
        }
    }
    return nil;
}

- (UIView *)subviewWithClass:(Class)argClass isRecursive:(BOOL)argIsRecursive {
    if (!argIsRecursive) {
        return [self subviewWithClass:argClass];
    }
    else {
        for (UIView *subView in self.subviews) {
            if (![subView isKindOfClass:argClass]) {
                id childSubView = [subView subviewWithClass:argClass isRecursive:YES];
                if (childSubView != nil) {
                    return childSubView;
                }
            }
            else {
                return subView;
            }
        }
    }
    return nil;
}

- (UIView *)subviewWithTagId:(NSInteger)argTagId {
    for (UIView *subView in self.subviews) {
        if (subView.tag == argTagId) {
            return subView;
        }
    }
    return nil;
}

- (UIView *)subviewWithTagId:(NSInteger)argTagId isRecursive:(BOOL)argIsRecursive {
    if (!argIsRecursive) {
        return [self subviewWithTagId:argTagId];
    }
    else {
        for (UIView *subView in self.subviews) {
            if (subView.tag != argTagId) {
                id childSubView = [subView subviewWithTagId:argTagId isRecursive:YES];
                if (childSubView != nil) {
                    return childSubView;
                }
            }
            else {
                return subView;
            }
        }
    }
    return nil;
}

- (void)removeAllSubviews {
    while (self.subviews.count) {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (void)setAdditionValue:(id)argValue forKey:(NSString *)argKey {
    if (self.additionValueDictionary == nil) {
        self.additionValueDictionary = [NSMutableDictionary dictionary];
    }
    if (argValue == nil) {
        return;
    }
    [self.additionValueDictionary setObject:argValue forKey:argKey];
}

- (id)valueForAdditionKey:(NSString *)argKey {
    if (self.additionValueDictionary == nil) {
        return nil;
    }
    return self.additionValueDictionary[argKey];
}

- (void)removeAdditionValueForKey:(NSString *)argKey {
    if (self.additionValueDictionary == nil) {
        self.additionValueDictionary = [NSMutableDictionary dictionary];
    }
    [self.additionValueDictionary removeObjectForKey:argKey];
}

- (void)showBadge:(NSInteger)argInteger {
    if (argInteger < 0) {
        //nothing
    }
    else if (argInteger == 0) {
        //隐藏Badge
        UIView *badgeView = [self viewWithTag:kTMOBadgeViewTag];
        if (badgeView) {
            [badgeView removeFromSuperview];
        }
    }
    else {
        UILabel *badgeView = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-11, -11, 22, 22)];
        badgeView.tag = kTMOBadgeViewTag;
        badgeView.backgroundColor = [UIColor redColor];
        badgeView.textColor = [UIColor whiteColor];
        badgeView.font = [UIFont systemFontOfSize:16.0];
        badgeView.textAlignment = NSTextAlignmentCenter;
        badgeView.layer.cornerRadius = 11.0f;
        badgeView.layer.masksToBounds = YES;
        if (argInteger < 10) {
            [badgeView setText:[NSString stringWithFormat:@"%d", argInteger]];
            badgeView.frame = CGRectMake(self.frame.size.width-13, -9, 22, 22);
        }
        else if (argInteger >= 10 && argInteger <= 99) {
            [badgeView setText:[NSString stringWithFormat:@"%d", argInteger]];
            badgeView.frame = CGRectMake(self.frame.size.width-15, -9, 26, 22);
        }
        else if (argInteger >= 100 && argInteger <= 999) {
            [badgeView setText:[NSString stringWithFormat:@"%d", argInteger]];
            badgeView.frame = CGRectMake(self.frame.size.width-20, -9, 36, 22);
        }
        else if (argInteger >= 1000) {
            [badgeView setText:@"999"];
            badgeView.frame = CGRectMake(self.frame.size.width-20, -9, 36, 22);
        }
        [self addSubview:badgeView];
    }
}

@end
