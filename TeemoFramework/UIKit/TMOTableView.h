//
//  TMOTableView.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-18.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMORefreshControl : UIView

@property (nonatomic, readonly) BOOL isRefreshing;

@end

@interface TMOLoadMoreControl : UIView

@property (nonatomic, readonly) BOOL isLoading;

@property (nonatomic, assign) BOOL isInvalid;

@property (nonatomic, assign) BOOL isFail;

@end

@interface TMOTableView : UITableView

typedef void(^TMOTableviewCallback)(TMOTableView *tableView, id viewController);

@property (nonatomic, readonly) BOOL isValid;

@property (nonatomic, strong) TMORefreshControl *myRefreshControl;

@property (nonatomic, strong) TMOLoadMoreControl *myLoadMoreControl;

- (void)refreshDone;

- (void)refreshWithCallback:(TMOTableviewCallback)argCallback withDelay:(NSTimeInterval)argDelay;

- (void)refreshAndScrollToTop;

- (void)loadMoreDone;

- (void)loadMoreWithCallback:(TMOTableviewCallback)argCallback withDelay:(NSTimeInterval)argDelay;

@end
