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
    
    [TMOHTTPManager simpleGet:@"http://api.map.baidu.com/geocoder?address=%E4%B8%8A%E5%9C%B0%E5%8D%81%E8%A1%9710%E5%8F%B7&output=json&key=37492c0ee6f924cb5e934fa08c6b1676" completionBlock:^(TMOHTTPResult *result, NSError *error) {
        [self.view smartyRendWithDictionary:result.JSONObj isRecursive:NO];
//        NSLog(@"一个最简单的HTTP请求,JSON:%@",result.JSONObj);
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
