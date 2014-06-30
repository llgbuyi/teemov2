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

@property (nonatomic, strong) SmartyTestObject *testObject;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation TMOSmartyViewController

- (void)dealloc {
    [self.view smartyUnBind];//如果你使用了bind方法，请务必在dealloc处保留此句，以保证KVO平衡
}

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
    self.testObject = [[SmartyTestObject alloc] init];
    self.testObject.status = @"OK";
    self.testObject.result = [[SmartyTestObjectItem alloc] init];
    self.testObject.result.level = @"道路";
    self.testObject.result.location = @{@"lng": @"123.123", @"lat":@"233.233"};
    
    [self.view smartyBindForSubviews];//RAC绑定数据源
    
    [self.statusLabel smartyBindWithBlock:^(UIView *bindView, id dataSource, id bindObject, NSString *key, id newValue) {
        //数据源变化后，将会执行此Block
        if ([newValue isEqualToString:@"NOTOK"]) {
            [(UILabel *)bindView setBackgroundColor:[UIColor yellowColor]];
            [(UILabel *)bindView setTextColor:[UIColor redColor]];
        }
        else {
            [(UILabel *)bindView setBackgroundColor:[UIColor clearColor]];
            [(UILabel *)bindView setTextColor:[UIColor blackColor]];
        }
    }];
    
    [self.view smartyRendWithObject:self.testObject isRecursive:YES];//初次渲染
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //数据源变化，View自动变化
        self.testObject.status = @"NOTOK";
        self.testObject.result.level = @"公路";
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.testObject.status = @"OK";
        self.testObject.result.level = @"铁路";
    });
    
    /**
     *  使用NSDictionary方式作为数据源
     */
//    [TMOHTTPManager simpleGet:@"http://api.map.baidu.com/geocoder?address=%E4%B8%8A%E5%9C%B0%E5%8D%81%E8%A1%9710%E5%8F%B7&output=json&key=37492c0ee6f924cb5e934fa08c6b1676" completionBlock:^(TMOHTTPResult *result, NSError *error) {
//        [self.view smartyRendWithDictionary:result.JSONObj isRecursive:NO];
//    }];
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