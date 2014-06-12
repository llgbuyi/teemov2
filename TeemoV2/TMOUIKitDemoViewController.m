//
//  TMOUIKitDemoViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-15.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOUIKitDemoViewController.h"
#import "TMOUIKitCore.h"

@interface TMOUIKitDemoViewController ()

@end

@implementation TMOUIKitDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"UIKit";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view hideHUD];
}

- (void)colorDemo {
    [self.view setBackgroundColor:[UIColor colorWithHex:@"#333333"]];//使用16制作色值
    [self.view setBackgroundColor:[UIColor colorWithRedUseInteger:233 green:233 blue:233 alpha:1.0]];//使用整数RGB色值
}

- (void)imageDemo {
    UIImage *pureImage = [UIImage imageWithPureColor:[UIColor blueColor]];
    [self.navigationController.navigationBar setBackgroundImage:pureImage forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDemo {
    //指示器
    [[self.view showHUDWithLoadingView] setUserInteractionEnabled:NO];//显示一个指示器
    
    //给view设定值
    [self.view setAdditionValue:@"123123" forKey:@"theKey"];
    [self.view setAdditionValue:@{@"123": @"123"} forKey:@"theDict"];
    NSLog(@"%@",[self.view valueForAdditionKey:@"theDict"]);
}

- (void)imageViewDemo {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    imageView.cacheTime = 600;
//    imageView.placeHolderImageName = @"123.png";
//    imageView.errorImageName = @"321.png";
    [imageView loadImageWithURLString:@"http://huanju.cn/s/v1206/pic-banner01.jpg"];
}

- (void)buttonImageViewDemo {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    [self.view addSubview:button];
    [button setCustomImageView:^(UIImageView *imageView) {
        [imageView loadImageWithURLString:@"http://huanju.cn/s/v1206/pic-banner01.jpg"];
    }];
    
    [button addTarget:self action:@selector(handleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)handleButtonTapped:(id)sender {
    NSLog(@"hello");
}

- (void)macrosDemo {
    NSLog(@"TMO_UIKIT_APP_HEIGHT:%f",TMO_UIKIT_APP_HEIGHT);
    NSLog(@"TMO_UIKIT_APP_IS_3_5INCH:%d",TMO_UIKIT_APP_IS_3_5INCH);
    NSLog(@"TMO_UIKIT_APP_IS_4_0INCH:%d",TMO_UIKIT_APP_IS_4_0INCH);
    NSLog(@"TMO_UIKIT_APP_IS_IOS7:%d",TMO_UIKIT_APP_IS_IOS7);
    NSLog(@"TMO_UIKIT_APP_IS_PAD:%d",TMO_UIKIT_APP_IS_PAD);
    NSLog(@"TMO_UIKIT_APP_WIDTH:%f",TMO_UIKIT_APP_WIDTH);
    NSLog(@"TMO_UIKIT_DEVICE_HEIGHT:%f",TMO_UIKIT_DEVICE_HEIGHT);
    NSLog(@"TMO_UIKIT_DEVICE_IS_RETINA:%d",TMO_UIKIT_DEVICE_IS_RETINA);
    NSLog(@"TMO_UIKIT_DEVICE_WIDTH:%f",TMO_UIKIT_DEVICE_WIDTH);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
