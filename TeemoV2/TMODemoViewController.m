//
//  TMODemoViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-15.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMODemoViewController.h"
#import "TMONetworkDemoViewController.h"
#import "TMOKVDBDemoViewController.h"
#import "TMOFMDBDemoViewController.h"
#import "TMOUIKitDemoViewController.h"
#import "TMOSmartyViewController.h"
#import "TMOSmartyMoreViewController.h"
#import "TMOStringDemoViewController.h"
#import "TMOTextKitViewController.h"
#import "TMOTableDataViewController.h"

#import "TMOUIKitCore.h"

@interface TMODemoViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *hello;

@end

@implementation TMODemoViewController

- (void)dealloc {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Demo";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //这里开始我们的使用示例，这里的示例包括了本框架所有的功能
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma makr - TableViewDelegate & Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }
    else if (section == 1){
        return 2;
    }
    else if (section == 2){
        return 10;
    }
    else if (section == 3){
        return 3;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"Tcp/Http"];
            [cell.detailTextLabel setText:@"常规请求"];
        }
        else if (indexPath.row == 1) {
            [cell.textLabel setText:@"Tcp/Http"];
            [cell.detailTextLabel setText:@"Host绑定请求"];
        }
        else if (indexPath.row == 2) {
            [cell.textLabel setText:@"Tcp/Http"];
            [cell.detailTextLabel setText:@"下载文件"];
        }
        else if (indexPath.row == 3) {
            [cell.textLabel setText:@"Tcp/Http"];
            [cell.detailTextLabel setText:@"上传文件"];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"KVDB"];
            [cell.detailTextLabel setText:@"高效的NOSQL数据库"];
        }
        else if (indexPath.row == 1) {
            [cell.textLabel setText:@"FMDB"];
            [cell.detailTextLabel setText:@"传统的SQLITE数据库"];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"UIColor扩展"];
        }
        else if (indexPath.row == 1) {
            [cell.textLabel setText:@"UIImage扩展"];
        }
        else if (indexPath.row == 2) {
            [cell.textLabel setText:@"UIView扩展"];
        }
        else if (indexPath.row == 3) {
            [cell.textLabel setText:@"UIImageView扩展"];
        }
        else if (indexPath.row == 4) {
            [cell.textLabel setText:@"UIButton扩展（自定义ImageView）"];
        }
        else if (indexPath.row == 5) {
            [cell.textLabel setText:@"模板语法"];
        }
        else if (indexPath.row == 6) {
            [cell.textLabel setText:@"模板语法（全示例）"];
        }
        else if (indexPath.row == 7) {
            [cell.textLabel setText:@"UIKit宏"];
        }
        else if (indexPath.row == 8) {
            [cell.textLabel setText:@"PonyTextKit"];
        }
        else if (indexPath.row == 9) {
            [cell.textLabel setText:@"UITableView扩展"];
            [cell.detailTextLabel setText:@"下拉刷新 上拉加载"];
        }
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"NSString扩展"];
        }
        else if (indexPath.row == 1) {
            [cell.textLabel setText:@"对象格式化"];
        }
        else if (indexPath.row == 2) {
            [cell.textLabel setText:@"ToolKit宏"];
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"NetworkKit";
    }
    else if (section == 1) {
        return @"DataKit";
    }
    else if (section == 2) {
        return @"UIKit";
    }
    else if (section == 3) {
        return @"ToolKit";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            TMONetworkDemoViewController *networkDemoViewController = [[TMONetworkDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:networkDemoViewController animated:YES];
            [networkDemoViewController demo1];
        }
        else if (indexPath.row == 1) {
            TMONetworkDemoViewController *networkDemoViewController = [[TMONetworkDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:networkDemoViewController animated:YES];
            [networkDemoViewController demo2];
        }
        else if (indexPath.row == 2) {
            TMONetworkDemoViewController *networkDemoViewController = [[TMONetworkDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:networkDemoViewController animated:YES];
            [networkDemoViewController demo3];
        }
        else if (indexPath.row == 3) {
            [[[UIAlertView alloc] initWithTitle:@"上传功能Demo还未做好" message:@"不过，上传功能实际上是可用的" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[[TMOKVDBDemoViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
        }
        else if (indexPath.row == 1) {
            [self.navigationController pushViewController:[[TMOFMDBDemoViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            TMOUIKitDemoViewController *uikitDemoViewController = [[TMOUIKitDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:uikitDemoViewController animated:YES];
            [uikitDemoViewController colorDemo];
        }
        else if (indexPath.row == 1) {
            TMOUIKitDemoViewController *uikitDemoViewController = [[TMOUIKitDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:uikitDemoViewController animated:YES];
            [uikitDemoViewController imageDemo];
        }
        else if (indexPath.row == 2) {
            TMOUIKitDemoViewController *uikitDemoViewController = [[TMOUIKitDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:uikitDemoViewController animated:YES];
            [uikitDemoViewController viewDemo];
        }
        else if (indexPath.row == 3) {
            TMOUIKitDemoViewController *uikitDemoViewController = [[TMOUIKitDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:uikitDemoViewController animated:YES];
            [uikitDemoViewController imageViewDemo];
        }
        else if (indexPath.row == 4) {
            TMOUIKitDemoViewController *uikitDemoViewController = [[TMOUIKitDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:uikitDemoViewController animated:YES];
            [uikitDemoViewController buttonImageViewDemo];
        }
        else if (indexPath.row == 5) {
            TMOSmartyViewController *smartyDemoViewController = [[TMOSmartyViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:smartyDemoViewController animated:YES];
        }
        else if (indexPath.row == 6) {
            TMOSmartyMoreViewController *smartyDemoViewController = [[TMOSmartyMoreViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:smartyDemoViewController animated:YES];

        }
        else if (indexPath.row == 7) {
            TMOUIKitDemoViewController *uikitDemoViewController = [[TMOUIKitDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:uikitDemoViewController animated:YES];
            [uikitDemoViewController macrosDemo];
        }
        else if (indexPath.row == 8) {
            TMOTextKitViewController *textKitDemoViewController = [[TMOTextKitViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:textKitDemoViewController animated:YES];
        }
        else if (indexPath.row == 9) {
            TMOTableDataViewController *tableDemoViewController = [[TMOTableDataViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:tableDemoViewController animated:YES];
        }
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            TMOStringDemoViewController *stringDemoViewController = [[TMOStringDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:stringDemoViewController animated:YES];
            [stringDemoViewController stringDemo];
        }
        else if (indexPath.row == 1) {
            TMOStringDemoViewController *stringDemoViewController = [[TMOStringDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:stringDemoViewController animated:YES];
            [stringDemoViewController objectDemo];
        }
        else if (indexPath.row == 2) {
            TMOStringDemoViewController *stringDemoViewController = [[TMOStringDemoViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:stringDemoViewController animated:YES];
            [stringDemoViewController macroDemo];
        }
    }
}

@end
