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
        self.numbersOfRow0 = 5;
        self.numbersOfRow1 = 5;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView refreshWithCallback:^(TMOTableView *tableView, TMOTableDataViewController *viewController) {
        viewController.numbersOfRow0 = arc4random() % 10;
        viewController.numbersOfRow1 = arc4random() % 10;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tableView refreshDone];
        });
    } withDelay:0.0];

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
    
    [self.tableView refreshAndScrollToTop];
    
//    [self.tableView refreshControlStart:^(UITableView *tableView, id viewController) {
//        numbersOfRow0 = arc4random() % 10;
//        numbersOfRow1 = arc4random() % 10;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [tableView refreshControlDone];
//        });
//    } withDelay:0.0];
////    return;
//    [self.tableView loadMoreStart:^(UITableView *tableView, id viewController) {
//        if (arc4random() % 10 < 5) {
//            [tableView loadMoreFail];
//            return ;
//        }
//        numbersOfRow1+=10;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [tableView loadMoreDone];
//            if (numbersOfRow1 > 100) {
//                [tableView loadMoreInvalid:YES];
//            }
//        });
//    } withDelay:0.0];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView loadMoreStart:^(UITableView *tableView, id viewController) {
//            numbersOfRow1+=10;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [tableView loadMoreDone];
//                if (numbersOfRow1 > 100) {
//                    [tableView loadMoreInvalid:YES];
//                }
//            });
//        } withDelay:0.0];
//    });
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

@end
