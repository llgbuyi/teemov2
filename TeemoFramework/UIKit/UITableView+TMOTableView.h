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

- (UIRefreshControl *)refreshControlStart:(refreshControlCallback)argCallback withDelay:(NSTimeInterval)argDelay;

- (void)refreshControlDone;

- (void)refreshControlRemove;

@end
