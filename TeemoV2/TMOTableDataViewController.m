//
//  TMOTableDataViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-17.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOTableDataViewController.h"
#import "TMOUIKitCore.h"

@interface TMOTableDataViewController ()<UITableViewDataSource, UITableViewDelegate>{
    NSUInteger numbersOfRow0;
    NSUInteger numbersOfRow1;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TMOTableDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"tableView";
        numbersOfRow0 = arc4random() % 10;
        numbersOfRow1 = arc4random() % 10;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView refreshControlStart:^(UITableView *tableView, id viewController) {
        numbersOfRow0 = arc4random() % 10;
        numbersOfRow1 = arc4random() % 10;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tableView refreshControlDone];
        });
    } withDelay:0.0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView loadMoreStart:^(UITableView *tableView, id viewController) {
            NSLog(@"123");
        } withDelay:0.0];
    });
    
    
    
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
        return numbersOfRow0;
    }
    else {
        return numbersOfRow1;
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
    }
    [cell.textLabel setText:[NSString stringWithFormat:@"Cell - %d",indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Hello - %d", section];
}

@end
