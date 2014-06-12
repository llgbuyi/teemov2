//
//  TMONetworkDemoViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-15.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMONetworkDemoViewController.h"
#import "TMOHTTPManager.h"

@interface TMONetworkDemoViewController ()

@end

@implementation TMONetworkDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Network";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)demo1 {
    //一个最简单的HTTP请求
    [TMOHTTPManager simpleGet:@"http://api.map.baidu.com/geocoder?address=%E4%B8%8A%E5%9C%B0%E5%8D%81%E8%A1%9710%E5%8F%B7&output=json&key=37492c0ee6f924cb5e934fa08c6b1676" completionBlock:^(TMOHTTPResult *result, NSError *error) {
        NSLog(@"一个最简单的HTTP请求,Result:%@",result);
        NSLog(@"一个最简单的HTTP请求,Text:%@",result.text);
        NSLog(@"一个最简单的HTTP请求,Data:%@",result.data);
        NSLog(@"一个最简单的HTTP请求,JSON:%@",result.JSONObj);
    }];
    
    //一个不简单的HTTP请求
    [[TMOHTTPManager shareInstance] fetchWithURL:@"http://api.map.baidu.com/geocoder?address=%E4%B8%8A%E5%9C%B0%E5%8D%81%E8%A1%9710%E5%8F%B7&output=json&key=37492c0ee6f924cb5e934fa08c6b1676" //URL
                                        postInfo:nil //若传入nil则表示这是一个GET请求，若传入字典，则表示这是一个POST请求
                                 timeoutInterval:60 //60秒后，此请求超时，并结束这个请求，将返回一个error
                                         headers:nil //HTTP请求HEADER，应传入一个字典
                                           owner:self //与comletionHandle结合使用
                                       cacheTime:-1 //请求的缓存时间，若小于0，则表示忽略缓存，并清除过往的缓存，若等于0则表示进行缓存且缓存是无限期的，若大于0，则表示缓存在N秒后失效
                                 fetcherPriority:TMOFetcherPriorityNormal //请求优先级，高优先级的请求会在队列中有插队的权利
                                 comletionHandle:@selector(callMe:error:) //SEL回调
                                 completionBlock:^(TMOHTTPResult *result, NSError *error) { //block回调
                                     NSLog(@"Block回调");
                                 }
     ];
    
    //一个无限期缓存的请求
    [[TMOHTTPManager shareInstance] fetchWithURL:@"http://www.baidu.com" postInfo:nil timeoutInterval:60 headers:nil owner:nil cacheTime:0 fetcherPriority:TMOFetcherPriorityNormal comletionHandle:nil completionBlock:^(TMOHTTPResult *result, NSError *error) {
        NSLog(@"www.baidu.com,length:%d", [result.text length]);
    }];
}

- (void)callMe:(TMOHTTPResult *)result error:(NSError *)error {
    if (error) {
        NSLog(@"加载失败");
    }
    else {
        NSLog(@"SEL回调");
        NSLog(@"%@",result.JSONObj);
    }
}

- (void)demo2 {
    [TMOHTTPManager shareInstance].hostDictionary = @{@"www.baidu.com": @"115.239.210.27"};//把百度域名绑定到指定IP
    [TMOHTTPManager simpleGet:@"http://www.baidu.com/" completionBlock:^(TMOHTTPResult *result, NSError *error) {
        NSLog(@"%@",result.text);//这里得到的所有结果都将是115.239.210.27服务器给予的
    }];
}

- (void)demo3 {
    [[TMOHTTPManager shareInstance] downloadWithURL:@"http://gdown.baidu.com/data/wisegame/6c036b36c4562c1d/WeChat_400.apk"
                                           postInfo:nil
                                    timeoutInterval:600
                                            headers:nil
                                              owner:nil
                                               path:[NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),@"WeChat_400.apk"]
                             receiveDataLengthBlock:^(NSUInteger currentLength, NSUInteger totalLength)
    {
        NSLog(@"下载进度：%ld/%ld", currentLength, totalLength);
    }
                             completeDownloadHandle:nil
                              completeDownloadBlock:^(NSError *error)
    {
        if (error) {
            NSLog(@"文件下载失败");
        }
        else {
            NSLog(@"文件已成功下载");
        }
        
    }];
}

- (void)demo4 {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
