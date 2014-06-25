//
//  TMOTableDataViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-17.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOTableDataViewController.h"
#import "TMOUIKitCore.h"

@interface TMOTableDataViewController ()<UITableViewDataSource, UITableViewDelegate, TMORefreshControlDelegate, TMOLoadMoreControlDelegate>

@property (weak, nonatomic) IBOutlet TMOTableView *tableView;

@property (nonatomic, assign) NSUInteger numbersOfRow0;
@property (nonatomic, assign) NSUInteger numbersOfRow1;

@end

@implementation TMOTableDataViewController

- (void)dealloc {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"tableView";
        self.numbersOfRow0 = 0;
        self.numbersOfRow1 = 0;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView firstLoadWithBlock:^(TMOTableView *tableView, TMOTableDataViewController *viewController) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            viewController.numbersOfRow0 = arc4random() % 10;
            viewController.numbersOfRow1 = arc4random() % 10;
            [tableView.myFirstLoadControl fail];
        });
    } withLoadingView:nil withFailView:nil];
    
//    [self.tableView refreshWithCallback:^(TMOTableView *tableView, TMOTableDataViewController *viewController) {
//        viewController.numbersOfRow0 = arc4random() % 10;
//        viewController.numbersOfRow1 = arc4random() % 10;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [tableView refreshDone];
//        });
//    } withDelay:3.0];
//
//    [self.tableView loadMoreWithCallback:^(TMOTableView *tableView, TMOTableDataViewController *viewController) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (arc4random() % 10 < 3) {
//                tableView.myLoadMoreControl.isFail = YES;//模拟加载失败
//                return ;
//            }
//            viewController.numbersOfRow1 += 10;
//            [tableView loadMoreDone];
//            if (viewController.numbersOfRow1 > 100) {
//                tableView.myLoadMoreControl.isInvalid = YES;
//            }
//        });
//    } withDelay:0.0];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"自定义样式开启");
//        self.tableView.myRefreshControl.delegate = self;
//        self.tableView.myLoadMoreControl.delegate = self;
//    });
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - TableView Delegate & Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.numbersOfRow0;
    }
    else {
        return self.numbersOfRow1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    [cell.textLabel setText:[NSString stringWithFormat:@"Cell - %d",indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Hello - %d", section];
}


#pragma mark - 
#pragma mark - TMORefreshControlDelegate

- (UIView *)refreshView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.frame = CGRectMake(0, 20, 320, 3);
    if (TMO_UIKIT_APP_IS_IOS7) {
        progressView.tintColor = [UIColor orangeColor];
    }
    [backgroundView addSubview:progressView];
    return backgroundView;
}

- (void)refreshViewInProcess:(UIView *)argCustomRefreshView withProcess:(CGFloat)argProcess {
    UIProgressView *progessView = (UIProgressView *)[argCustomRefreshView subviewWithClass:[UIProgressView class]];
    [progessView setProgress:argProcess animated:NO];
}

- (void)refreshViewWillStartRefresh:(UIView *)argCustomRefreshView {
    UIProgressView *progessView = (UIProgressView *)[argCustomRefreshView subviewWithClass:[UIProgressView class]];
    [progessView setProgress:1.0];
    if (TMO_UIKIT_APP_IS_IOS7) {
        [progessView setTintColor:[UIColor greenColor]];
    }
}

- (void)refreshViewWillEndRefresh:(UIView *)argCustomRefreshView {
    UIProgressView *progessView = (UIProgressView *)[argCustomRefreshView subviewWithClass:[UIProgressView class]];
    if (TMO_UIKIT_APP_IS_IOS7) {
        [progessView setTintColor:[UIColor orangeColor]];
    }
    [progessView setProgress:0.0 animated:NO];
}

#pragma mark - 
#pragma mark - TMOLoadMoreControlDelegate

- (UIView *)loadMoreView {
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
    [aLabel setBackgroundColor:[UIColor whiteColor]];
    [aLabel setTextAlignment:NSTextAlignmentCenter];
    [aLabel setFont:[UIFont systemFontOfSize:18.0]];
    [aLabel setText:@"有种你再拉啊！"];
    return aLabel;
}

- (void)loadMoreViewWillStartLoading:(UILabel *)argCustomView {
    [argCustomView setText:@"讨厌，人家正在加载更多啦"];
}

- (void)loadMoreViewWillEndLoading:(UILabel *)argCustomView {
    [argCustomView setText:@"有种你再拉啊！"];
}

- (void)loadMoreViewLoadFail:(UILabel *)argCustomView {
    [argCustomView setText:@"人家累啦！"];
}

@end
