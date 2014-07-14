//
//  TMOTableDataViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-17.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOTableDataViewController.h"
#import "TMOUIKitCore.h"

@interface TMOTableDataViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet TMOTableView *tableView;

@property (nonatomic, assign) NSUInteger numberOfRowsInSection0;
@property (nonatomic, assign) NSUInteger numberOfRowsInSection1;

@end

@implementation TMOTableDataViewController

- (void)dealloc {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"tableView";
        self.numberOfRowsInSection0 = 0;
        self.numberOfRowsInSection1 = 0;
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFirstLoad];//When set up finished, it will execute Immediately.
    [self setupRefreshControl];
    [self setupLoadMore];
}

- (void)setupFirstLoad {
    UIView *customLoadingView = nil;
    UIView *customFailView = nil;//You can custom all Views.
    
    //    {
    //        customLoadingView = [[UIView alloc] initWithFrame:self.view.frame];
    //        customLoadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //        [customLoadingView setBackgroundColor:[UIColor grayColor]];
    //    }
    //
    //    {
    //        customFailView = [[UIView alloc] initWithFrame:self.view.frame];
    //        customFailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //        [customFailView setBackgroundColor:[UIColor yellowColor]];
    //    }
    
    [self.tableView firstLoadWithBlock:^(TMOTableView *tableView, TMOTableDataViewController *viewController) {
        //do something load data jobs
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (arc4random() % 10 < 3) {
                //We try to make load data jobs fail, and you can see what happen.
                [tableView.myFirstLoadControl fail];
            }
            else {
                viewController.numberOfRowsInSection0 = 5;
                viewController.numberOfRowsInSection1 = 8;
                [tableView.myFirstLoadControl done];//You don't need to use [tableView reloadData].
            }
        });
    } withLoadingView:customLoadingView withFailView:customFailView];
    
    self.tableView.myFirstLoadControl.allowRetry = YES;//set YES makes failView can response user tap retry. Default is NO.
}

- (void)setupRefreshControl {
    [self.tableView refreshWithCallback:^(TMOTableView *tableView, TMOTableDataViewController *viewController) {
        viewController.numberOfRowsInSection0 = arc4random() % 10;
        viewController.numberOfRowsInSection1 = arc4random() % 10;
        [tableView.myRefreshControl done];
    } withDelay:1.5];//Really easy to use.
    //Don't use self in block! Use tableView, viewController. It will 'Circular references'.
    //不要在Block中使用self!使用tableView和viewController代替，或者传入一个weak self，否则会导致循环引用。
    
    
    //Here is a custom refreshControl
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.myRefreshControl setRefreshView:[self refreshView]];
        [self.tableView.myRefreshControl setProcessingBlock:^(UIView *refreshView, CGFloat progress) {
            UIProgressView *progessView = (UIProgressView *)[refreshView viewWithTag:1];
            [progessView setProgress:progress animated:NO];
        }];
        [self.tableView.myRefreshControl setStartBlock:^(UIView *refreshView) {
            UIProgressView *progessView = (UIProgressView *)[refreshView viewWithTag:1];
            [progessView setProgress:1.0];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                [progessView setTintColor:[UIColor greenColor]];
            }
        }];
        [self.tableView.myRefreshControl setStopBlock:^(UIView *refreshView) {
            UIProgressView *progessView = (UIProgressView *)[refreshView viewWithTag:1];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                [progessView setTintColor:[UIColor orangeColor]];
            }
            [progessView setProgress:0.0 animated:NO];
        }];
    });
    
}

- (IBAction)doRefresh:(id)sender {
    [self.tableView.myRefreshControl refreshAndScrollToTop];
}

- (void)setupLoadMore {
    [self.tableView loadMoreWithCallback:^(TMOTableView *tableView, TMOTableDataViewController *viewController) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (arc4random() % 10 < 4) {
                //try to fail
                [tableView.myLoadMoreControl fail];
            }
            else {
                viewController.numberOfRowsInSection1 += 10;
                [tableView.myLoadMoreControl done];
            }
        });
    } withDelay:0.0];
    
    //Here is a custom loadMoreControl
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.myLoadMoreControl setLoadMoreView:[self loadMoreView]];
        [self.tableView.myLoadMoreControl setStartBlock:^(UIView *loadMoreView) {
            [(UILabel *)loadMoreView setText:@"Loading..."];
        }];
        [self.tableView.myLoadMoreControl setStopBlock:^(UIView *loadMoreView) {
            [(UILabel *)loadMoreView setText:@"Drop down LoadMore"];
        }];
        [self.tableView.myLoadMoreControl setFailBlock:^(UIView *loadMoreView) {
            [(UILabel *)loadMoreView setText:@"Load fail!"];
        }];
        
        [self.tableView.myLoadMoreControl setLoadMoreCallback:^(TMOTableView *tableView, TMOTableDataViewController *viewController) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (viewController.numberOfRowsInSection1 > 50) {
                    [tableView.myLoadMoreControl invalid:YES hide:NO];
                    [(UILabel *)tableView.myLoadMoreControl.loadMoreView setText:@"All Data Loaded."];
                }
                else if (arc4random() % 10 < 4) {
                    //try to fail
                    [tableView.myLoadMoreControl fail];
                }
                else {
                    viewController.numberOfRowsInSection1 += 10;
                    [tableView.myLoadMoreControl done];
                }
            });
        }];
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.numberOfRowsInSection0;
    }
    else if (section == 1) {
        return self.numberOfRowsInSection1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Cell:%d", indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Hello - %d", section];
}



//And now you can customize refreshView & loadMoreView

- (UIView *)refreshView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.tag = 1;
    progressView.frame = CGRectMake(0, 20, 320, 3);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        progressView.tintColor = [UIColor orangeColor];
    }
    [backgroundView addSubview:progressView];
    return backgroundView;
}

- (UIView *)loadMoreView {
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
    [aLabel setBackgroundColor:[UIColor whiteColor]];
    [aLabel setTextAlignment:NSTextAlignmentCenter];
    [aLabel setFont:[UIFont systemFontOfSize:18.0]];
    [aLabel setText:@"Drop down LoadMore"];
    return aLabel;
}

@end
