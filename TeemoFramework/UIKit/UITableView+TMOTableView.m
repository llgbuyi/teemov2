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
#import "TMOToolKitCore.h"

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
        
        if (self.scrollView.contentOffset.y < -48.0 && !_isRefreshing) {
            _isRefreshing = YES;
            [self.activityView beginRefreshing];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.scrollView performSelector:@selector(refreshControlDidStart) withObject:nil];
#pragma clang diagnostic pop
        }
        
        CGFloat currentY = -MIN(0.0, self.scrollView.contentOffset.y);
        if (currentY < 16.0) {
            [self.activityView setTimeOffset:0.0];
        }
        else {
            CGFloat offset = (MIN(currentY, 48.0) - 16.0) / (48.0 - 16.0);
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

@interface TMOLoadMoreView : UIView{
    BOOL _isLoading;
}

@property (nonatomic, assign) BOOL isInvalid;

@property (nonatomic, assign) NSTimeInterval delay;

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

- (void)setInvalid:(BOOL)isInvalid {
    if (isInvalid) {
        self.isInvalid = YES;
        [self.scrollView setContentInset:UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, 0, 0)];
        [self stopLoading];
        [self setAlpha:0.0];
    }
    else {
        self.isInvalid = NO;
        [self.scrollView setContentInset:UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, 44, 0)];
        [self setAlpha:1.0];
    }
}

- (void)setup {
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    self.retryButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.scrollView action:@selector(loadMoreDidStart)];
#pragma clang diagnostic pop
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
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityView setFrame:CGRectMake(138, 0, 44, 44)];
    [self addSubview:self.activityView];
    [self.activityView startAnimating];
    [self.activityView setAlpha:0.0];
    
    [self.scrollView setContentInset:UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, 44, 0)];
}

- (void)addScrollViewObserver:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (!self.isInvalid && [keyPath isEqualToString:@"contentSize"]) {
        [self setFrame:CGRectMake(0, self.scrollView.contentSize.height, 320, 44)];
        [self setAlpha:1.0];
    }
    else if ([keyPath isEqualToString:@"contentOffset"]) {
        if (!_isLoading && !self.isInvalid && (self.scrollView.contentSize.height - self.scrollView.contentOffset.y) < self.scrollView.frame.size.height + 20.0) {
            //执行block
            _isLoading = YES;
            [self.activityView setAlpha:1.0];
            [self.toolBar setAlpha:0.0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.scrollView performSelector:@selector(loadMoreDidStart) withObject:nil];
#pragma clang diagnostic pop
        }
    }
    
}

- (void)stopLoading {
    _isLoading = NO;
    [self setAlpha:0.0];
    [self.activityView setAlpha:0.0];
    [self.toolBar setAlpha:1.0];
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
    TMOLoadMoreView *loadMoreView = (TMOLoadMoreView *)[self viewWithTag:kTMOTableViewLoadMoreViewTag];
    if (loadMoreView != nil) {
        loadMoreView.isInvalid = YES;
        [loadMoreView stopLoading];
    }
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
    TMOLoadMoreView *loadMoreView = (TMOLoadMoreView *)[self viewWithTag:kTMOTableViewLoadMoreViewTag];
    if (loadMoreView != nil) {
        [self loadMoreInvalid:NO];
    }
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
    loadMoreView.delay = argDelay;
    [self addSubview:loadMoreView];
    [loadMoreView addScrollViewObserver:self];
}

- (void)loadMoreDidStart {
    TMOLoadMoreView *loadMoreView = (TMOLoadMoreView *)[self viewWithTag:kTMOTableViewLoadMoreViewTag];
    if (loadMoreView.callback != nil) {
        refreshControlCallback callback = loadMoreView.callback;
        [self performSelectorOnMainThread:@selector(loadMoreCallbackWillCall) withObject:nil waitUntilDone:YES];
        NSTimeInterval delay = MIN(loadMoreView.delay, 0.25);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                callback(self, [self myViewController]);
        });
    }
}

- (void)loadMoreInvalid:(BOOL)isInvalid {
    TMOLoadMoreView *loadMoreView = (TMOLoadMoreView *)[self viewWithTag:kTMOTableViewLoadMoreViewTag];
    if (loadMoreView != nil) {
        [loadMoreView setInvalid:isInvalid];
    }
}

- (void)loadMoreDone {
    TMOLoadMoreView *loadMoreView = (TMOLoadMoreView *)[self viewWithTag:kTMOTableViewLoadMoreViewTag];
    if (loadMoreView != nil && !loadMoreView.isInvalid) {
        BOOL needReload = NO;
        NSMutableArray *indexPathsAdding = [NSMutableArray array];
        NSUInteger oldSectionCount = TOInteger([self valueForAdditionKey:@"loadMoreSectionCount"]);
        NSUInteger newSectionCount = [[self dataSource] numberOfSectionsInTableView:self];
        if (newSectionCount != oldSectionCount) {
            needReload = YES;
        }
        else {
            for (NSUInteger currentSection = 0; currentSection < oldSectionCount; currentSection++) {
                NSString *key = [NSString stringWithFormat:@"loadMoreRowCount_%d", currentSection];
                NSUInteger oldRowCount = TOInteger([self valueForAdditionKey:key]);
                NSUInteger newRowCount = [[self dataSource] tableView:self numberOfRowsInSection:currentSection];
                if (newRowCount < oldRowCount) {
                    needReload = YES;
                    break;
                }
                else if (newRowCount == oldRowCount) {
                    //do nothing
                }
                else {
                    for (NSUInteger currentRow = oldRowCount - 1; currentRow < newRowCount - 1; currentRow++) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRow inSection:currentSection];
                        [indexPathsAdding addObject:indexPath];
                    }
                }
            }
        }
        if (needReload) {
            [self reloadData];
            [loadMoreView stopLoading];
        }
        else {
            if ([indexPathsAdding count] > 0) {
                [self beginUpdates];
                [self insertRowsAtIndexPaths:indexPathsAdding withRowAnimation:UITableViewRowAnimationNone];
                [self endUpdates];
                [loadMoreView stopLoading];
            }
        }
    }
}

- (void)loadMoreCallbackWillCall {
    NSUInteger sectionCount = [[self dataSource] numberOfSectionsInTableView:self];
    [self setAdditionValue:@(sectionCount) forKey:@"loadMoreSectionCount"];
    for (NSUInteger currentSection = 0; currentSection < sectionCount; currentSection++) {
        NSUInteger rowCount = [[self dataSource] tableView:self numberOfRowsInSection:currentSection];
        [self setAdditionValue:@(rowCount)
                        forKey:[NSString stringWithFormat:@"loadMoreRowCount_%d", currentSection]];
    }
}

@end
