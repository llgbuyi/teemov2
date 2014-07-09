//
//  TMOKVDBDemoViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-15.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOKVDBDemoViewController.h"
#import "TMOKVDB.h"

@interface TMOKVDBDemoViewController ()

@end

@implementation TMOKVDBDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"TMONetworkDemoViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"KVDB";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LevelDB *db = [TMOKVDB defaultDatabase];//使用系统默认的KVDB库
    [db setObject:@"SetSomething" forKey:@"theKey"];//你可以直接存入任何对象
    NSLog(@"%@",[db valueForKey:@"theKey"]);
    
    LevelDB *customDb = [TMOKVDB customDatabase:@"myCustom"];//使用一个新库存储对象
    [customDb setObject:@"otherThings" forKey:@"theKey"];
    NSLog(@"%@",[customDb valueForKey:@"theKey"]);
    
    NSLog(@"cachesize:%lld",[TMOKVDB sizeOfPath:nil]);
    [TMOKVDB closeAndReleaseSpace:@"default"];
    
    LevelDB *customPath = [TMOKVDB customDatabase:[NSString stringWithFormat:@"%@tmpKVDB/",NSTemporaryDirectory()]];//把KV库保存至指定路径
    [customPath setObject:@"123123" forKey:@"ccc"];
    NSLog(@"%@",[customPath valueForKey:@"ccc"]);
    
    // 测试多线程操作同一个数据库
    [self reuseLevelKVDB];
    
    // Do any additional setup after loading the view.
}

- (void)reuseLevelKVDB {
    for (int i = 0; i < 1000; i ++) {
        // 打开1000条新的子线程去操作同一个数据库文件
        [NSThread detachNewThreadSelector:@selector(setupSomeDataToKVDB) toTarget:self withObject:nil];
        if (i == 500) {
            [NSThread detachNewThreadSelector:@selector(removeSomeKVDB) toTarget:self withObject:nil];
        } else if (i == 700) {
            [NSThread detachNewThreadSelector:@selector(removeSomeKVDB) toTarget:self withObject:nil];
        }
    }
}

- (void)removeSomeKVDB {
    [TMOKVDB closeAndReleaseSpace:[NSString stringWithFormat:@"%@tmpKVDB/",NSTemporaryDirectory()]];
    NSLog(@"删除了数据库");
}

- (void)setupSomeDataToKVDB {
    // 同一个KVDB数据库
    LevelDB *customPath = [TMOKVDB customDatabase:[NSString stringWithFormat:@"%@tmpKVDB/",NSTemporaryDirectory()]];//把KV库保存至指定路径
    
    for (int i = 0; i < 10; i ++) {
        if (![customPath setObject:@"123123" forKey:@"ccc"]) {
            NSLog(@"失败了");
        }
        sleep(0.1);
        if (![customPath setObject:@"setupSomeDataToKVDB" forKey:@"setupSomeDataToKVDB"]) {
            NSLog(@"失败了");
        }
    }
    NSLog(@"setupSomeDataToKVDB");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
