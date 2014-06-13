//
//  TMOFMDBDemoViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-15.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOFMDBDemoViewController.h"
#import "TMOFMDB.h"

@interface TMOFMDBDemoViewController ()

@end

@implementation TMOFMDBDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[TMOFMDB defaultDatabase] inDatabase:^(FMDatabase *db) {
        [db selectWithCallback:^(NSArray *result) {
            [[TMOFMDB defaultDatabase] inDatabase:^(FMDatabase *db) {
                NSArray *newResult = [db selectWithSql:@"select * from sqlite_master"];
                NSLog(@"%@",newResult);
            }];
        } withSql:@"select * from sqlite_master"];
    }];
    
    [[TMOFMDB defaultDatabase] inDatabaseRunOnMainThread:^(FMDatabase *db) {
        [[[UIAlertView alloc] initWithTitle:@"12313" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
    }];
    
    FMDatabaseQueue *queue = [TMOFMDB defaultDatabase];//这将默认保存在tmp目录下一个数据文件中
    [queue inDatabase:^(FMDatabase *db) { //建议使用此方式，线程安全
        TMOFMDBTableScheme *scheme = [[TMOFMDBTableScheme alloc] init];
        scheme.tableName = @"test_table";
        scheme.columnScheme =
        @[
            [TMOFMDBColumnScheme schemeWithName:@"id" type:TMOFMDBColumnTypeInteger index:TMOFMDBColumnIndexPrimaryKey],
            [TMOFMDBColumnScheme schemeWithName:@"name" type:TMOFMDBColumnTypeText index:TMOFMDBColumnIndexNone],
            [TMOFMDBColumnScheme schemeWithName:@"other" type:TMOFMDBColumnTypeText index:TMOFMDBColumnIndexNone]
        ];
        [db createTable:scheme];//建表，这样建表的好处是，程序会自动识别表结构是否为最新，若否，则将自动改变表结构
    }];
    
    
    [queue inDatabase:^(FMDatabase *db) {//由于有了队列机制，这些语句必定会在建表后才会执行
        [db executeUpdate:@"insert into test_table values(?,?,?)", [NSNull null], @"PonyCui", @"呵呵"];
        [db executeUpdate:@"insert into test_table values(?,?,?)", [NSNull null], @"PonyCui", @"呵呵"];
        [db executeUpdate:@"insert into test_table values(?,?,?)", [NSNull null], @"PonyCui", @"呵呵"];
        [db executeUpdate:@"insert into test_table values(?,?,?)", [NSNull null], @"PonyCui", @"呵呵"];
        [db executeUpdate:@"insert into test_table values(?,?,?)", [NSNull null], @"PonyCui", @"呵呵"];
    }];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db selectWithCallback:^(NSArray *result) {
            NSLog(@"%@",result);
        } withSql:@"select * from test_table"];//读出表中所有数据，异步回调
        
        NSDictionary *item = [db findWithSql:@"select * from test_table"];//同步读出表中一条数据
        NSLog(@"%@",item);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
