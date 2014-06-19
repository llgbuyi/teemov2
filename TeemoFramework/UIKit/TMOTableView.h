//
//  TMOTableView.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-18.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMORefreshControl : UIView

/**
 *  下拉刷新是否正在执行，只读
 */
@property (nonatomic, readonly) BOOL isRefreshing;

@end

@interface TMOLoadMoreControl : UIView

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

@interface TMOTableView : UITableView

/**
 *  Rrefresh & LoadMore Callback Block
 *
 *  @param tableView      使用此变量以避免循环引用，使用前，调用前请使用 tableView.isValid 检测 tableView 是否已经失效
 *  @param viewController 代表tableView的父级viewController，使用此变量以避免循环引用
 */
typedef void(^TMOTableviewCallback)(TMOTableView *tableView, id viewController);

/**
 *  tableView是否已经移出superView，若已经移出，则勿执行任何UI相关操作
 */
@property (nonatomic, readonly) BOOL isValid;

/**
 *  下拉刷新控制器，使用refreshWithCallback:withDelay:执行初始化
 */
@property (nonatomic, readonly) TMORefreshControl *myRefreshControl;

/**
 *  上拉加载控制器，使用loadMoreWithCallback:withDelay:执行初始化
 */
@property (nonatomic, readonly) TMOLoadMoreControl *myLoadMoreControl;

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
