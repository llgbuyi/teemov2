//
//  UITableView+TMOTableView.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-16.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#define kTMOTableViewRefreshViewTag -10002
#define kTMOTableViewLoadMoreViewTag -10003

#import "UITableView+TMOTableView.h"
#import "UIView+TMOView.h"
#import "XHActivityIndicatorView.h"
#import "TMOUIKitMacro.h"
#import "UIImage+TMOImage.h"

@interface TMORefreshControlView : UIView{
    BOOL _isRefreshing;
}

@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, strong) XHActivityIndicatorView *activityView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) refreshControlCallback callback;

@end

@implementation TMORefreshControlView

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 48)];
    if (self) {
        self.tag = kTMOTableViewRefreshViewTag;
        self.activityView = [[XHActivityIndicatorView alloc] initWithFrame:CGRectMake(160, 22, 44, 44)];
        self.activityView.tintColor = [UIColor grayColor];
        [self addSubview:self.activityView];
    }
    return self;
}

- (void)addScrollViewObserver:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        if (_isRefreshing) {
            if (self.scrollView.contentOffset.y > -48.0) {
                CGFloat adjustInset = -MIN(self.scrollView.contentOffset.y, 0.0);
                [self.scrollView setContentInset:UIEdgeInsetsMake(adjustInset,
                                                                  0,
                                                                  self.scrollView.contentInset.bottom,
                                                                  0)];
            }
        }
        
        if (self.scrollView.contentOffset.y < -66.0 && !_isRefreshing) {
            _isRefreshing = YES;
            [self.activityView beginRefreshing];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.scrollView performSelector:@selector(refreshControlDidStart) withObject:nil];
#pragma clang diagnostic pop
            [self.scrollView setContentInset:UIEdgeInsetsMake(48, 0, self.scrollView.contentInset.bottom, 0)];
        }
        
        CGFloat currentY = -MIN(0.0, self.scrollView.contentOffset.y);
        if (currentY < 16.0) {
            [self.activityView setTimeOffset:0.0];
        }
        else {
            CGFloat offset = (MIN(currentY, 66.0) - 16.0) / (66.0 - 16.0);
            [self.activityView setTimeOffset:offset];
        }
    }
}

- (void)stopRefresh {
    _isRefreshing = NO;
    [self.activityView setTimeOffset:0.0];
    [self.activityView endRefreshing];
    [UIView animateWithDuration:0.15 animations:^{
        [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, self.scrollView.contentInset.bottom, 0)];
    }];
    
}

@end

@interface TMOLoadMoreView : UIView

@property (nonatomic, strong) UIToolbar *toolBar;

@property (nonatomic, strong) UIBarButtonItem *retryButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) refreshControlCallback callback;

@end

@implementation TMOLoadMoreView

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super initWithFrame:CGRectMake(0, scrollView.contentSize.height, 320, 44)];
    if (self) {
        self.scrollView = scrollView;
        self.tag = kTMOTableViewLoadMoreViewTag;
        [self setup];
    }
    return self;
}

- (void)setup {
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.retryButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.scrollView action:@selector(loadMoreDidStart)];
    UIBarButtonItem *fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixItem.width = 138.0;
    UIBarButtonItem *fixItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixItem2.width = 138.0;
    [self.toolBar setItems:@[fixItem, self.retryButton, fixItem2]];
    [self addSubview:self.toolBar];
    
    if (TMO_UIKIT_APP_IS_IOS7) {
        [self.toolBar setBackgroundImage:[UIImage imageWithPureColor:[UIColor clearColor]]
                      forToolbarPosition:UIBarPositionAny
                              barMetrics:UIBarMetricsDefault];
        self.toolBar.barStyle = UIBarStyleBlackTranslucent;
        [self.retryButton setTintColor:[UIColor grayColor]];
    }
    else {
        //toolBar.barStyle = UIBarStyleBlackTranslucent;
        [self.toolBar setBackgroundImage:[UIImage imageWithPureColor:[UIColor clearColor]]
                      forToolbarPosition:UIBarPositionAny
                              barMetrics:UIBarMetricsDefault];
    }
    [self.scrollView setContentInset:UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, 44, 0)];
}

- (void)addScrollViewObserver:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self setFrame:CGRectMake(0, self.scrollView.contentSize.height, 320, 44)];
    }
    else if ([keyPath isEqualToString:@"contentOffset"]) {
        if ((self.scrollView.contentSize.height - self.scrollView.contentOffset.y) < self.scrollView.frame.size.height + 20.0) {
            //执行block
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.scrollView performSelector:@selector(loadMoreDidStart) withObject:nil];
#pragma clang diagnostic pop
        }
    }
    
}

@end

@implementation UITableView (TMOTableView)

#pragma mark - 
#pragma mark - refreshControl

- (void)refreshControlStart:(refreshControlCallback)argCallback withDelay:(NSTimeInterval)argDelay {
    [self.superview addSubview:[self myRefreshView]];
    [[self myRefreshView] setDelay:argDelay];
    [self.superview bringSubviewToFront:self];
    [self setBackgroundColor:[UIColor clearColor]];
    [[self myRefreshView] setCallback:argCallback];
    [[self myRefreshView] addScrollViewObserver:self];
}

- (void)refreshControlDidStart {
    if ([[self myRefreshView] callback] != nil) {
        refreshControlCallback callback = [[self myRefreshView] callback];
        if ([[self myRefreshView] delay] > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([[self myRefreshView] delay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                callback(self, [self myViewController]);
            });
        }
        else {
            callback(self, [self myViewController]);
        }
        
    }
}

- (UIViewController *)myViewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)refreshControlDone {
    [[self myRefreshView] stopRefresh];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];//refresh，always reloadData.
    });
}

- (TMORefreshControlView *)myRefreshView {
    TMORefreshControlView *view;
    view = (TMORefreshControlView *)[self.superview viewWithTag:kTMOTableViewRefreshViewTag];
    if (view == nil) {
        view = [[TMORefreshControlView alloc] init];
    }
    return view;
}

#pragma mark -
#pragma mark - load More

- (void)loadMoreStart:(refreshControlCallback)argCallback withDelay:(NSTimeInterval)argDelay {
    TMOLoadMoreView *loadMoreView = [[TMOLoadMoreView alloc] initWithScrollView:self];
    loadMoreView.callback = argCallback;
    [self addSubview:loadMoreView];
    [loadMoreView addScrollViewObserver:self];
}

- (void)loadMoreDidStart {
    TMOLoadMoreView *loadMoreView = (TMOLoadMoreView *)[self viewWithTag:kTMOTableViewLoadMoreViewTag];
    if (loadMoreView.callback != nil) {
        refreshControlCallback callback = loadMoreView.callback;
        if ([[self myRefreshView] delay] > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([[self myRefreshView] delay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                callback(self, [self myViewController]);
            });
        }
        else {
            callback(self, [self myViewController]);
        }
        
    }
}

- (void)loadMoreInvalid:(BOOL)isInvalid {
    UIView *loadMoreView = [self viewWithTag:kTMOTableViewLoadMoreViewTag];
    if (loadMoreView != nil) {
        if (isInvalid) {
            [loadMoreView setAlpha:0.0];
            [self setContentInset:UIEdgeInsetsMake(self.contentInset.top, 0, 0, 0)];
        }
        else {
            [loadMoreView setAlpha:1.0];
            [self setContentInset:UIEdgeInsetsMake(self.contentInset.top, 0, 44, 0)];
        }
    }
    
}

- (void)loadMoreDone {
    [self reloadData];
}

- (void)loadMoreCallbackWillCall {
    NSUInteger sectionCount = [[self dataSource] numberOfSectionsInTableView:self];
    [self setAdditionValue:@(sectionCount) forKey:@"refreshControlSectionCount"];
    for (NSUInteger currentSection = 0; currentSection < sectionCount; currentSection++) {
        NSUInteger rowCount = [[self dataSource] tableView:self numberOfRowsInSection:currentSection];
        [self setAdditionValue:@(rowCount)
                        forKey:[NSString stringWithFormat:@"refreshControlRowCount_%d", currentSection]];
    }
}

@end
