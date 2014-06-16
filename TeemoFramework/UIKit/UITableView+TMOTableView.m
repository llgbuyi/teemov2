//
//  UITableView+TMOTableView.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-16.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "UITableView+TMOTableView.h"
#import "UIView+TMOView.h"

@implementation UITableView (TMOTableView)

- (UIRefreshControl *)refreshControlStart:(refreshControlCallback)argCallback withDelay:(NSTimeInterval)argDelay {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlDidStart:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setAdditionValue:argCallback forKey:@"refreshControlCallback"];
    [refreshControl setAdditionValue:@(argDelay) forKey:@"refreshControlCallbackDelay"];
    [self addSubview:refreshControl];
    return refreshControl;
}

- (void)refreshControlDidStart:(id)sender {
    UIRefreshControl *refreshControl = (UIRefreshControl *)[self subviewWithClass:[UIRefreshControl class]];
    if (refreshControl != nil) {
        [refreshControl beginRefreshing];
        refreshControlCallback beCallback = [refreshControl valueForAdditionKey:@"refreshControlCallback"];
        if (beCallback != nil) {
            beCallback(self);
        }
    }
}

- (void)refreshControlDone {
    UIRefreshControl *refreshControl = (UIRefreshControl *)[self subviewWithClass:[UIRefreshControl class]];
    if (refreshControl != nil) {
        [refreshControl endRefreshing];
    }
}

- (void)refreshControlRemove {
    UIRefreshControl *refreshControl = (UIRefreshControl *)[self subviewWithClass:[UIRefreshControl class]];
    if (refreshControl != nil) {
        [refreshControl setAdditionValue:@"" forKey:@"refreshControlCallback"];
        [refreshControl removeFromSuperview];
    }
}

@end
