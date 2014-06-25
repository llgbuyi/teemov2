//
//  TMOTableView.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-18.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOTableView.h"
#import "XHActivityIndicatorView.h"
#import "TMOToolKitCore.h"
#import "TMOUIKitMacro.h"
#import "UIImage+TMOImage.h"

@interface TMORefreshControl (){
    CGFloat _controlViewHeight;
}

@property (nonatomic, strong) XHActivityIndicatorView *activityView;

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, weak) TMOTableView *tableView;

@property (nonatomic, strong) TMOTableviewCallback callback;

@property (nonatomic, assign) NSTimeInterval delay;

- (id)initWithTableView:(TMOTableView *)argTabelView;

- (void)refreshAndScrollToTop;

- (void)stop;

@end

@interface TMOLoadMoreControl (){
    CGFloat _controlViewHeight;
}

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, strong) UIToolbar *toolBar;

@property (nonatomic, strong) UIBarButtonItem *retryButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, weak) TMOTableView *tableView;

@property (nonatomic, strong) TMOTableviewCallback callback;

@property (nonatomic, assign) NSTimeInterval delay;

- (id)initWithTableView:(TMOTableView *)argTabelView;

- (void)stop;

@end


@interface TMOTableView ()

@end

@implementation TMOTableView

- (void)dealloc {
    if (self.myRefreshControl != nil) {
        [self removeObserver:self.myRefreshControl forKeyPath:@"contentOffset"];
    }
    if (self.myLoadMoreControl != nil) {
        [self removeObserver:self.myLoadMoreControl forKeyPath:@"contentOffset"];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setHasPlaceHolder:(BOOL)hasPlaceHolder {
    if (hasPlaceHolder) {
        [self.superview addSubview:self.placeHolderView];
        [self.superview sendSubviewToBack:self.placeHolderView];
        [self resetPlaceHolderView];
    }
    else {
        [self.placeHolderView removeFromSuperview];
    }
}

- (UIView *)placeHolderView {
    if (_placeHolderView == nil) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        UIActivityIndicatorView *juhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [juhua setColor:[UIColor grayColor]];
        juhua.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        juhua.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        [juhua startAnimating];
        [backgroundView addSubview:juhua];
        _placeHolderView = backgroundView;
    }
    return _placeHolderView;
}

- (void)resetPlaceHolderView {
    if (self.dataSource != nil) {
        NSUInteger allRowsCount = 0;
        for (NSUInteger currentSection = 0; currentSection < [self.dataSource numberOfSectionsInTableView:self]; currentSection++) {
            allRowsCount += [self.dataSource tableView:self
                                 numberOfRowsInSection:currentSection];
        }
        if (allRowsCount == 0) {
            [self.placeHolderView setAlpha:1.0];
            [self setAlpha:0.0];
            [self.myRefreshControl setAlpha:0.0];
            [self.myLoadMoreControl setAlpha:0.0];
        }
        else {
            [self setAlpha:1.0];
            [self.placeHolderView setAlpha:0.0];
            [self.myRefreshControl setAlpha:1.0];
            [self.myLoadMoreControl setAlpha:1.0];
        }
    }
    else {
        [self.placeHolderView setAlpha:1.0];
        [self setAlpha:0.0];
        [self.myRefreshControl setAlpha:1.0];
        [self.myLoadMoreControl setAlpha:1.0];
    }
}

- (void)setup {
}

- (BOOL)isValid {
    return self.superview != nil;
}

- (void)reloadData {
    if (!self.isValid) {
        return;
    }
    
    if (self.myLoadMoreControl != nil) {
        self.myLoadMoreControl.alpha = 0;
    }
    [super reloadData];
    if (self.myLoadMoreControl != nil) {
        [self.myLoadMoreControl setFrame:CGRectMake(0, self.contentSize.height, 320, 44)];
        self.myLoadMoreControl.alpha = 1;
    }
    [self resetPlaceHolderView];
}

- (void)refreshDone {
    if (!self.isValid) {
        return;
    }
    [self reloadData];
    [self.myRefreshControl performSelector:@selector(stop) withObject:nil afterDelay:0.5];
}

- (void)loadMoreDone {
    if (!self.isValid) {
        return;
    }
    if (self.myLoadMoreControl != nil && self.myLoadMoreControl.isInvalid == YES) {
        [self.myLoadMoreControl stop];
        return;
    }
    [self reloadData];
    [self.myLoadMoreControl stop];
}

- (void)refreshWithCallback:(TMOTableviewCallback)argCallback withDelay:(NSTimeInterval)argDelay {
    _myRefreshControl = [[TMORefreshControl alloc] initWithTableView:self];
    [self.myRefreshControl setDelay:argDelay];
    [self.myRefreshControl setCallback:argCallback];
    [self.superview addSubview:self.myRefreshControl];
    [self.superview bringSubviewToFront:self];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)refreshAndScrollToTop {
    if (self.myRefreshControl != nil) {
        [self.myRefreshControl refreshAndScrollToTop];
    }
}

- (void)loadMoreWithCallback:(TMOTableviewCallback)argCallback withDelay:(NSTimeInterval)argDelay {
    _myLoadMoreControl = [[TMOLoadMoreControl alloc] initWithTableView:self];
    [self.myLoadMoreControl setDelay:argDelay];
    [self.myLoadMoreControl setCallback:argCallback];
    [self addSubview:self.myLoadMoreControl];
}

@end

@implementation TMORefreshControl

- (void)dealloc {
    
}

- (instancetype)initWithTableView:(TMOTableView *)argTabelView {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 60)];
    if (self) {
        _controlViewHeight = 60;
        self.tableView = argTabelView;
        [self defaultSetup];
        [self addScrollViewObserver];
    }
    return self;
}

- (void)setDelegate:(id<TMORefreshControlDelegate>)delegate {
    if (delegate != nil) {
        _delegate = delegate;
        [self.activityView removeFromSuperview];
        self.customView = [self.delegate refreshView];
        _controlViewHeight = self.customView.frame.size.height;
        self.frame = CGRectMake(0, 0, 320, _controlViewHeight);
        [self addSubview:self.customView];
    }
    else {
        [self.customView removeFromSuperview];
        _delegate = nil;
        [self defaultSetup];
    }
}

- (void)defaultSetup {
    self.frame = CGRectMake(0, 0, 320, 60);
    _controlViewHeight = 60;
    self.activityView = [[XHActivityIndicatorView alloc] initWithFrame:CGRectMake(160, 26, 44, 44)];
    self.activityView.tintColor = [UIColor grayColor];
    [self addSubview:self.activityView];
}

- (void)addScrollViewObserver {
    [self.tableView addObserver:self
                     forKeyPath:@"contentOffset"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        if (self.isRefreshing) {
            if (self.tableView.contentOffset.y > -_controlViewHeight) {
                CGFloat adjustInset = -MIN(self.tableView.contentOffset.y, 0.0);
                [self.tableView setContentInset:UIEdgeInsetsMake(adjustInset,
                                                                 0,
                                                                 self.tableView.contentInset.bottom,
                                                                 0)];
            }
        }
        
        if (self.tableView.contentOffset.y < -_controlViewHeight && !_isRefreshing) {
            _isRefreshing = YES;
            if (self.delegate != nil &&
                [self.delegate respondsToSelector:@selector(refreshViewWillStartRefresh:)]) {
                [[self delegate] refreshViewWillStartRefresh:self.customView];
            }
            else if (self.delegate == nil) {
                [self.activityView beginRefreshing];
            }
            [self start];
        }
        
        if (!self.isRefreshing) {
            CGFloat currentY = -MIN(0.0, self.tableView.contentOffset.y);
            if (currentY < 16.0) {
                if (self.delegate == nil) {
                    [self.activityView setTimeOffset:0.0];
                }
            }
            else {
                CGFloat offset = (MIN(currentY, _controlViewHeight) - 16.0) / (_controlViewHeight - 16.0);
                if (self.delegate != nil &&
                    [self.delegate respondsToSelector:@selector(refreshViewInProcess:withProcess:)]) {
                    [[self delegate] refreshViewInProcess:self.customView withProcess:offset];
                }
                else if (self.delegate == nil) {
                    [self.activityView setTimeOffset:offset];
                }
            }
        }
        
    }
}

- (void)stop {
    _isRefreshing = NO;
    if (self.delegate != nil && [[self delegate] respondsToSelector:@selector(refreshViewWillEndRefresh:)]) {
        [self.delegate refreshViewWillEndRefresh:self.customView];
    }
    else if (self.delegate == nil) {
        [self.activityView setTimeOffset:0.0];
        [self.activityView endRefreshing];
    }
    [UIView animateWithDuration:0.15 animations:^{
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, self.tableView.contentInset.bottom, 0)];
    }];
}

- (void)refreshAndScrollToTop {
    if (!self.isRefreshing) {
        _isRefreshing = YES;
        if (self.delegate != nil &&
            [self.delegate respondsToSelector:@selector(refreshViewWillStartRefresh:)]) {
            [[self delegate] refreshViewWillStartRefresh:self.customView];
        }
        else if (self.delegate == nil) {
            [self.activityView setTimeOffset:1.0];
            [self.activityView beginRefreshing];
        }
        [self start];
        [UIView animateWithDuration:0.15 animations:^{
            [self.tableView setContentInset:UIEdgeInsetsMake(_controlViewHeight,
                                                             0,
                                                             self.tableView.contentInset.bottom,
                                                             0)];
            [self.tableView setContentOffset:CGPointMake(0, -_controlViewHeight) animated:YES];
        }];
    }
}

- (void)start {
    if (self.callback != nil) {
        if (self.delay > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.callback(self.tableView, [self scrollViewParentViewController]);
            });
        }
        else {
            self.callback(self.tableView, [self scrollViewParentViewController]);
        }
    }
}

- (UIViewController *)scrollViewParentViewController {
    for (UIView *next = [self.tableView superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end

@implementation TMOLoadMoreControl

- (id)initWithTableView:(TMOTableView *)argTabelView {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {
        self.tableView = argTabelView;
        [self defaultSetup];
        self.isInvalid = NO;
        [self.tableView addObserver:self
                         forKeyPath:@"contentOffset"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
    }
    return self;
}

- (void)setDelegate:(id<TMOLoadMoreControlDelegate>)delegate {
    if (delegate != nil) {
        _delegate = delegate;
        [self.toolBar removeFromSuperview];
        [self.activityView removeFromSuperview];
        self.customView = [[self delegate] loadMoreView];
        [self addSubview:self.customView];
        _controlViewHeight = self.customView.frame.size.height;
        self.frame = CGRectMake(0, self.tableView.contentSize.height, 320, _controlViewHeight);
        [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, _controlViewHeight, 0)];
    }
    else {
        [self.customView removeFromSuperview];
        [self defaultSetup];
    }
}

- (void)defaultSetup {
    _controlViewHeight = 44.0;
    self.frame = CGRectMake(0, 0, 320, 44);
    [self addSubview:self.toolBar];
    [self addSubview:self.activityView];
    [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, _controlViewHeight, 0)];
}

- (UIToolbar *)toolBar {
    if (_toolBar == nil) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        if (TMO_UIKIT_APP_IS_IOS7) {
            [_toolBar setBackgroundImage:[UIImage imageWithPureColor:[UIColor clearColor]]
                      forToolbarPosition:UIBarPositionAny
                              barMetrics:UIBarMetricsDefault];
            _toolBar.barStyle = UIBarStyleBlackTranslucent;
        }
        else {
            //toolBar.barStyle = UIBarStyleBlackTranslucent;
            [_toolBar setBackgroundImage:[UIImage imageWithPureColor:[UIColor clearColor]]
                      forToolbarPosition:UIBarPositionAny
                              barMetrics:UIBarMetricsDefault];
        }
        UIBarButtonItem *fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixItem.width = 138.0;
        UIBarButtonItem *fixItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixItem2.width = 138.0;
        [_toolBar setItems:@[fixItem, self.retryButton, fixItem2]];
    }
    return _toolBar;
}

- (UIBarButtonItem *)retryButton {
    if (_retryButton == nil) {
        _retryButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                     target:self
                                                                     action:@selector(handleRetryButtonTapped)];
        if (TMO_UIKIT_APP_IS_IOS7) {
            [_retryButton setTintColor:[UIColor grayColor]];
        }
    }
    return _retryButton;
}

- (UIActivityIndicatorView *)activityView {
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityView setFrame:CGRectMake(138, 0, 44, 44)];
        [_activityView startAnimating];
        [_activityView setAlpha:0.0];
    }
    return _activityView;
}

- (void)setIsInvalid:(BOOL)isInvalid {
    if (isInvalid) {
        _isInvalid = YES;
        [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 0, 0)];
        [self stop];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setAlpha:0.0];
        });
    }
    else {
        _isInvalid = NO;
        [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, _controlViewHeight, 0)];
        [self setAlpha:1.0];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (!_isLoading && !self.isInvalid && !self.isFail &&
            (self.tableView.contentSize.height - self.tableView.contentOffset.y) < self.tableView.frame.size.height + 20.0) {
            //执行block
            _isLoading = YES;
            [self start];
        }
        else if (!_isLoading && !self.isInvalid && self.isFail &&
                 (self.tableView.contentSize.height - self.tableView.contentOffset.y) < self.tableView.frame.size.height - 100) {
            //大力拉，重试
            _isFail = NO;
            _isLoading = YES;
            [self start];
        }
    }
}

- (void)start {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loadMoreViewWillStartLoading:)]) {
        [[self delegate] loadMoreViewWillStartLoading:self.customView];
    }
    else if (self.delegate == nil) {
        [self.toolBar setAlpha:0.0];
        [self.activityView setAlpha:1.0];
    }
    if (self.callback != nil) {
        if (self.delay > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.callback(self.tableView, [self scrollViewParentViewController]);
            });
        }
        else {
            self.callback(self.tableView, [self scrollViewParentViewController]);
        }
    }
}

- (void)stop {
    [self setAlpha:0.0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loadMoreViewWillEndLoading:)]) {
            [[self delegate] loadMoreViewWillEndLoading:self.customView];
        }
        else if (self.delegate == nil) {
            [self.activityView setAlpha:0.0];
            [self.toolBar setAlpha:1.0];
        }
        [self setAlpha:1.0];
        _isLoading = NO;
    });
}

- (void)setIsFail:(BOOL)isFail {
    if (isFail) {
        //do Fail
        _isFail = YES;
        _isLoading = NO;
        [self setAlpha:1.0];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loadMoreViewLoadFail:)]) {
            [[self delegate] loadMoreViewLoadFail:self.customView];
        }
        else {
            [self.toolBar setAlpha:1.0];
            [self.activityView setAlpha:0.0];
        }
    }
    else {
        //retry
        _isFail = NO;
        [self setAlpha:1.0];
        [self start];
    }
}

- (void)handleRetryButtonTapped {
    self.isFail = NO;
}

- (UIViewController *)scrollViewParentViewController {
    for (UIView *next = [self.tableView superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
