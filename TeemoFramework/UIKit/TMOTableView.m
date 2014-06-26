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

@interface TMOFirstLoadControl ()

@property (nonatomic, assign) CGFloat yOffset;
@property (nonatomic, weak) TMOTableView *tableView;
@property (nonatomic, strong) TMOTableviewCallback callback;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIView *failView;
- (instancetype)initWithTableView:(TMOTableView *)argTabelView;
- (void)setup;

@end

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
@property (nonatomic, strong) UIView *retryView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, weak) TMOTableView *tableView;
@property (nonatomic, strong) TMOTableviewCallback callback;
@property (nonatomic, assign) NSTimeInterval delay;

- (id)initWithTableView:(TMOTableView *)argTabelView;
- (void)stop;

@end

@interface TMOSVGInfomationView : UIView

@end

@interface TMOSVGArrowDownView : UIView

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

- (void)firstLoadWithBlock:(TMOTableviewCallback)argBlock
           withLoadingView:(UIView *)argLoadingView
              withFailView:(UIView *)argFailView {
    _myFirstLoadControl = [[TMOFirstLoadControl alloc] initWithTableView:self];
    self.myFirstLoadControl.callback = argBlock;
    self.myFirstLoadControl.loadingView = argLoadingView;
    self.myFirstLoadControl.failView = argFailView;
    [self.myFirstLoadControl setup];
    [self.myFirstLoadControl start];
}

- (void)firstLoadWithBlock:(TMOTableviewCallback)argBlock
               withYOffset:(CGFloat)argYOffset {
    _myFirstLoadControl = [[TMOFirstLoadControl alloc] initWithTableView:self];
    self.myFirstLoadControl.callback = argBlock;
    self.myFirstLoadControl.yOffset = argYOffset;
    [self.myFirstLoadControl setup];
    [self.myFirstLoadControl start];
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
        [self.myLoadMoreControl setFrame:CGRectMake(0, self.contentSize.height, self.frame.size.width, 44)];
        self.myLoadMoreControl.alpha = 1;
    }
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
    self = [super initWithFrame:CGRectMake(0, 0, argTabelView.frame.size.width, 60)];
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
        [self.activityView.superview removeFromSuperview];
        self.customView = [self.delegate refreshView];
        _controlViewHeight = self.customView.frame.size.height;
        self.frame = CGRectMake(0, 0, self.tableView.frame.size.width, _controlViewHeight);
        [self addSubview:self.customView];
    }
    else {
        [self.customView removeFromSuperview];
        _delegate = nil;
        [self defaultSetup];
    }
}

- (void)defaultSetup {
    self.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 60);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _controlViewHeight = 60;
    self.activityView = [[XHActivityIndicatorView alloc] initWithFrame:CGRectMake(22, 22, 44, 44)];
    self.activityView.tintColor = [UIColor grayColor];
    
    UIView *activityParentView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2-22.0, 0, 44, 44)];
    [activityParentView addSubview:self.activityView];
    activityParentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self addSubview:activityParentView];
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
    self = [super initWithFrame:CGRectMake(0, 0, argTabelView.frame.size.width, 44)];
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
        [self.retryView removeFromSuperview];
        [self.activityView removeFromSuperview];
        self.customView = [[self delegate] loadMoreView];
        [self addSubview:self.customView];
        _controlViewHeight = self.customView.frame.size.height;
        self.frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.frame.size.width, _controlViewHeight);
        [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, _controlViewHeight, 0)];
    }
    else {
        [self.customView removeFromSuperview];
        [self defaultSetup];
    }
}

- (void)defaultSetup {
    _controlViewHeight = 44.0;
    self.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 44);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.retryView];
    [self addSubview:self.activityView];
    [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, _controlViewHeight, 0)];
}

- (UIView *)retryView {
    if (_retryView == nil) {
        _retryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        TMOSVGArrowDownView *arrowDown = [[TMOSVGArrowDownView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2-22.0, 0, 44, 44)];
        arrowDown.backgroundColor = [UIColor whiteColor];
        [_retryView addSubview:arrowDown];
        [_retryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRetryButtonTapped)]];
        arrowDown.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _retryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _retryView;
}

- (UIActivityIndicatorView *)activityView {
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityView setFrame:CGRectMake(self.tableView.frame.size.width/2-22.0, 0, 44, 44)];
        [_activityView startAnimating];
        [_activityView setAlpha:0.0];
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
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
        [self.retryView setAlpha:0.0];
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
            [self.retryView setAlpha:1.0];
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
            [self.retryView setAlpha:1.0];
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

@implementation TMOFirstLoadControl

- (instancetype)initWithTableView:(TMOTableView *)argTabelView {
    self = [super init];
    if (self) {
        self.yOffset = 44.0;
        self.tableView = argTabelView;
    }
    return self;
}

- (void)setup {
    if (self.tableView.superview != nil) {
        [self.tableView.superview addSubview:self.loadingView];
        [self.tableView.superview addSubview:self.failView];
        [self.loadingView setAlpha:0.0];
        [self.failView setAlpha:0.0];
    }
}

- (void)start {
    [self.tableView setAlpha:0.0];
    [self.loadingView setAlpha:1.0];
    [self.loadingView.superview bringSubviewToFront:self.loadingView];
    TMOTableviewCallback callback = self.callback;
    if (callback != nil) {
        callback(self.tableView, [self scrollViewParentViewController]);
    }
}

- (void)done {
    [self.tableView setAlpha:1.0];
    [self.loadingView setAlpha:0.0];
    [self.failView setAlpha:0.0];
    if ([self.tableView isValid]) {
        [self.tableView reloadData];
    }
}

- (void)fail {
    [self.tableView setAlpha:0.0];
    [self.failView setAlpha:1.0];
    [self.failView.superview bringSubviewToFront:self.failView];
    if (self.allowRetry) {
        if ([[self.failView gestureRecognizers] count] == 0) {
            [self.failView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(start)]];
        }
    }
    else {
        [self.failView setGestureRecognizers:@[]];
    }
}

- (UIView *)loadingView {
    if (_loadingView == nil) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        UIActivityIndicatorView *juhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [juhua setColor:[UIColor grayColor]];
        juhua.center = CGPointMake(self.tableView.frame.size.width/2, self.tableView.frame.size.height/2 - self.yOffset);
        juhua.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [juhua startAnimating];
        [backgroundView addSubview:juhua];
        _loadingView = backgroundView;
    }
    return _loadingView;
}

- (UIView *)failView {
    if (_failView == nil) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        TMOSVGInfomationView *iconView = [[TMOSVGInfomationView alloc] initWithFrame:CGRectMake(backgroundView.frame.size.width/2-48.0, backgroundView.frame.size.height/2-48.0-self.yOffset, 96.0, 116.0)];
        iconView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        iconView.backgroundColor = [UIColor whiteColor];
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 86, iconView.frame.size.width, 20)];
        errorLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [errorLabel setText:@"加载失败"];
        [errorLabel setTextColor:[UIColor grayColor]];
        [errorLabel setFont:[UIFont systemFontOfSize:16.0]];
        [errorLabel setBackgroundColor:[UIColor clearColor]];
        [errorLabel setTextAlignment:NSTextAlignmentCenter];
        [iconView addSubview:errorLabel];
        [backgroundView addSubview:iconView];
        _failView = backgroundView;
    }
    return _failView;
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


#pragma mark - 
#pragma mark - SVGViews

@implementation TMOSVGInfomationView

- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* color2 = [UIColor colorWithRed: 0.513 green: 0.508 blue: 0.509 alpha: 1];
    
    //// Group 4
    {
        //// Oval 2 Drawing
        UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(17, 18, 61.88, 61.88)];
        [color2 setStroke];
        oval2Path.lineWidth = 2;
        [oval2Path stroke];
        
        
        //// Oval 3 Drawing
        UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(44.35, 30.04, 7.61, 7.61)];
        [color2 setFill];
        [oval3Path fill];
        
        
        //// Rectangle 3 Drawing
        UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(46, 43, 4, 25)];
        [color2 setFill];
        [rectangle3Path fill];
    }
}

@end

@implementation TMOSVGArrowDownView

- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* color2 = [UIColor colorWithRed: 0.513 green: 0.508 blue: 0.509 alpha: 1];
    
    //// Group 137
    {
        //// Oval 75 Drawing
        UIBezierPath* oval75Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(12.33, 11.33, 21.67, 21.67)];
        [color2 setStroke];
        oval75Path.lineWidth = 1.96;
        [oval75Path stroke];
        
        
        //// Group 138
        {
            //// Bezier 373 Drawing
            UIBezierPath* bezier373Path = UIBezierPath.bezierPath;
            [bezier373Path moveToPoint: CGPointMake(22.98, 27.49)];
            [bezier373Path addLineToPoint: CGPointMake(17, 21.37)];
            [bezier373Path addLineToPoint: CGPointMake(22.98, 27.49)];
            [bezier373Path closePath];
            [color2 setStroke];
            bezier373Path.lineWidth = 1.96;
            [bezier373Path stroke];
            
            
            //// Bezier 374 Drawing
            UIBezierPath* bezier374Path = UIBezierPath.bezierPath;
            [bezier374Path moveToPoint: CGPointMake(22.48, 28)];
            [bezier374Path addLineToPoint: CGPointMake(28.83, 21.5)];
            [color2 setStroke];
            bezier374Path.lineWidth = 1.96;
            [bezier374Path stroke];
            
            
            //// Bezier 375 Drawing
            UIBezierPath* bezier375Path = UIBezierPath.bezierPath;
            [bezier375Path moveToPoint: CGPointMake(22.98, 26.47)];
            [bezier375Path addLineToPoint: CGPointMake(22.98, 15)];
            [color2 setStroke];
            bezier375Path.lineWidth = 2;
            [bezier375Path stroke];
        }
    }

}

@end
