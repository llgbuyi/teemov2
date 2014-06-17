//
//  UITableView+TMOTableView.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-16.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^refreshControlCallback)(UITableView *tableView, id viewController);

@interface UITableView (TMOTableView)

/**
 *  下拉刷新
 *
 *  @param argCallback 用户下拉刷新后执行的回调，不要将self传入block中，否则将导致循环引用
 *  @param argDelay    延迟n秒后执行回调
 */
- (void)refreshControlStart:(refreshControlCallback)argCallback withDelay:(NSTimeInterval)argDelay;

/**
 *  下拉刷新完成，并执行列表重新加载工作
 */
- (void)refreshControlDone;

/**
 *  上拉加载更多
 *
 *  @param argCallback 触发上拉加载后的回调，不要将self传入block中，否则将导致循环引用
 *  @param argDelay    延迟n秒后执行回调
 */
- (void)loadMoreStart:(refreshControlCallback)argCallback withDelay:(NSTimeInterval)argDelay;

- (void)loadMoreInvalid:(BOOL)isInvalid;

/**
 *  上拉加载完成
 *  将自动执行列表重载工作
 */
- (void)loadMoreDone;

@end
