//
//  TMOSmartyViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-15.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOSmartyViewController.h"
#import "TMOHTTPManager.h"
#import "TMOUIKitCore.h"

@class SmartyTestObject, SmartyTestObjectItem;

@interface SmartyTestObject : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) SmartyTestObjectItem *result;

@end

@interface SmartyTestObjectItem : NSObject

@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSString *level;

@end

@interface TMOSmartyViewController ()

@end

@implementation TMOSmartyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Smarty";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    /**
     *  使用NSObject方式作为数据源
     */
    SmartyTestObject *testObject = [[SmartyTestObject alloc] init];
    testObject.status = @"OK";
    testObject.result = [[SmartyTestObjectItem alloc] init];
    testObject.result.level = @"道路";
    testObject.result.location = @{@"lng": @"123.123", @"lat":@"233.233"};
    NSLog(@"123");
    [self.view smartyRendWithObject:testObject isRecursive:YES];
    NSLog(@"123313223");
    /**
     *  使用NSDictionary方式作为数据源
     */
//    [TMOHTTPManager simpleGet:@"http://api.map.baidu.com/geocoder?address=%E4%B8%8A%E5%9C%B0%E5%8D%81%E8%A1%9710%E5%8F%B7&output=json&key=37492c0ee6f924cb5e934fa08c6b1676" completionBlock:^(TMOHTTPResult *result, NSError *error) {
//        [self.view smartyRendWithDictionary:result.JSONObj isRecursive:NO];
//    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation SmartyTestObject

@end

@implementation SmartyTestObjectItem

@end