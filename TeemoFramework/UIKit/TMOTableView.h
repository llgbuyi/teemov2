//
//  TMOTableView.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-18.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMOTableView, TMORefreshControl, TMOLoadMoreControl;

@protocol TMORefreshControlDelegate <NSObject>

@optional

/**
 *  返回一个下拉刷新自定义样式的UIView
 *
 *  @return UIView
 */
- (UIView *)refreshView;

/**
 *  当用户下拉tableView直至触发刷新操作的过程中，TMORefreshControl会进行回调
 *
 *  @param argCustomRefreshView 已经自定义的UIView
 *  @param argProcess           float 0~1
 */
- (void)refreshViewInProcess:(UIView *)argCustomRefreshView withProcess:(CGFloat)argProcess;

/**
 *  触发刷新后的回调
 *
 *  @param argCustomRefreshView 已经自定义的UIView
 */
- (void)refreshViewWillStartRefresh:(UIView *)argCustomRefreshView;

/**
 *  刷新完毕后的回调
 *
 *  @param argCustomRefreshView 已经自定义的UIView
 */
- (void)refreshViewWillEndRefresh:(UIView *)argCustomRefreshView;

@end

@interface TMORefreshControl : UIView

/**
 *  下拉刷新，自定义样式Delegate
 */
@property (nonatomic, weak) id<TMORefreshControlDelegate> delegate;

/**
 *  下拉刷新是否正在执行，只读
 */
@property (nonatomic, readonly) BOOL isRefreshing;

@end

@protocol TMOLoadMoreControlDelegate <NSObject>

@optional

/**
 *  返回一个上拉加载自定式样式UIView
 *
 *  @return UIView
 */
- (UIView *)loadMoreView;

/**
 *  当上拉加载将要触发时，回调
 *
 *  @param argCustomView 已经自定义的UIView
 */
- (void)loadMoreViewWillStartLoading:(UIView *)argCustomView;

/**
 *  当上拉加载完成时，回调
 *
 *  @param argCustomView 已经自定义的UIView
 */
- (void)loadMoreViewWillEndLoading:(UIView *)argCustomView;

/**
 *  当上拉加载失败时，回调
 *
 *  @param argCustomView 已经自定义的UIView
 */
- (void)loadMoreViewLoadFail:(UIView *)argCustomView;

@end

@interface TMOLoadMoreControl : UIView

@property (nonatomic, weak) id<TMOLoadMoreControlDelegate> delegate;

/**
 *  上拉加载是否正在执行，只读
 */
@property (nonatomic, readonly) BOOL isLoading;

/**
 *  上拉加载是否生效
 *  传入YES，上拉加载失效
 *  传入NO，上拉加载生效
 */
@property (nonatomic, assign) BOOL isInvalid;

/**
 *  上拉加载是否为失败状态
 *  传入YES，停止任何尝试
 *  传入NO，继续尝试加载
 */
@property (nonatomic, assign) BOOL isFail;

@end

@interface TMOFirstLoadControl : NSObject

@property (nonatomic, assign) BOOL allowRetry;

- (void)start;
- (void)done;
- (void)fail;

@end

@interface TMOTableView : UITableView

/**
 *  Rrefresh & LoadMore Callback Block
 *
 *  @param tableView      使用此变量以避免循环引用，调用前请使用 tableView.isValid 检测 tableView 是否已经失效
 *  @param viewController 代表tableView的父级viewController，使用此变量以避免循环引用
 */
typedef void(^TMOTableviewCallback)(TMOTableView *tableView, id viewController);

/**
 *  tableView是否已经移出superView，若已经移出，则勿执行任何UI相关操作
 */
@property (nonatomic, readonly) BOOL isValid;

/**
 *  首次加载控制器
 */
@property (nonatomic, readonly) TMOFirstLoadControl *myFirstLoadControl;

/**
 *  下拉刷新控制器，使用refreshWithCallback:withDelay:执行初始化
 */
@property (nonatomic, readonly) TMORefreshControl *myRefreshControl;

/**
 *  上拉加载控制器，使用loadMoreWithCallback:withDelay:执行初始化
 */
@property (nonatomic, readonly) TMOLoadMoreControl *myLoadMoreControl;

/**
 *  首次加载控制器
 *  加载完成后，调用[myFirstLoadControl done]
 *  加载失败后，调用[myFirstLoadControl fail]
 *  如需要重试，调用[myFirstLoadControl start]
 *
 *  @param argBlock       加载Block
 *  @param argLoadingView 可选，一个自定义的loadingView
 *  @param argFailView    可选，一个自定义的failView
 */
- (void)firstLoadWithBlock:(TMOTableviewCallback)argBlock
           withLoadingView:(UIView *)argLoadingView
              withFailView:(UIView *)argFailView;

/**
 *  首次加载控制器，使用默认的样式
 *
 *  @param argBlock       加载Block
 *  @param argYOffset     菊花、失败提示Y偏移值
 */
- (void)firstLoadWithBlock:(TMOTableviewCallback)argBlock
               withYOffset:(CGFloat)argYOffset;

/**
 *  下拉刷新完成后，你需要执行此方法，此方法会为你完成菊花停转、表视图刷新等操作
 */
- (void)refreshDone;

/**
 *  下拉刷新初始化
 *
 *  @param argCallback 当下拉刷新被触发后执行的Block，切勿将self直接传入block，你需要传入一个weak的self，否则会引起循环引用
 *  @param argDelay    触发下拉刷新后，延时执行Block
 */
- (void)refreshWithCallback:(TMOTableviewCallback)argCallback withDelay:(NSTimeInterval)argDelay;

/**
 *  立即触发下拉刷新，并将tableView滑动至顶部
 */
- (void)refreshAndScrollToTop;

/**
 *  上拉加载完成后，你需要执行此方法，此方法会为你完成菊花停转、表视图刷新等操作
 */
- (void)loadMoreDone;

/**
 *  上拉加载初始化
 *
 *  @param argCallback 当上拉加载被触发后执行的Block，切勿将self直接传入block，你需要传入一个weak的self，否则会引起循环引用
 *  @param argDelay    触发上拉加载后，延时执行Block
 */
- (void)loadMoreWithCallback:(TMOTableviewCallback)argCallback withDelay:(NSTimeInterval)argDelay;

@end
