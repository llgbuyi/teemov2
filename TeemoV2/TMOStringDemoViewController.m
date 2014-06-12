//
//  TMOStringDemoViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-15.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOStringDemoViewController.h"
#import "TMOToolKitCore.h"

@interface TMOStringDemoViewController ()

@end

@implementation TMOStringDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"TMONetworkDemoViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"ToolKit";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)stringDemo {
    NSString *theString = @"string";
    NSLog(@"Md5:%@",[theString stringByMD5Hash]);
    NSLog(@"Sha1:%@",[theString stringBySha1Hash]);
    NSLog(@"Base64Encode:%@",[theString stringByBase64Encode]);
    NSString *url = @"http://www.baidu.com/?param=姐夫";
    NSLog(@"UrlEncode:%@",[url stringByURLEncode]);
    NSLog(@"Base64Decode:%@",[[theString stringByBase64Encode] stringByBase64Decode]);
    NSString *pity = @"     fhdslkajfhdsak      ";
    NSLog(@"Trim:%@",[pity stringByTrim]);
    NSLog(@"isBlank:%d",[pity isBlank]);
    NSLog(@"contains:%d",[pity contains:@"hds"]);
}

- (void)objectDemo {
    //如果你需要将任何对象转换为NSString
    TOString(@"fdajlkhs");
    TOString(@12313);
    TOString([NSNull null]);
    TOString(nil);
    TOString(@{});
    TOString(@[]);
    
    //同理，如果你需要将任何对转换为NSNumber
    TONumber(@"123");
    
    //NSArray
    TOArray(@[]);
    
    //NSDictionary
    TODictionary(@{});
    
    //TOInteger
    TOInteger(@"123");
    TOInteger(@123);
    
    //TOFloat
    TOFloat(@"123.123");
    TOFloat(@123.123);
    
    //同时，我们提供对象混乱器，用以检测你的程序是否已经完全做好对象转换工作
    NSDictionary *theDictionary = @{@"a": @"123",
                                    @"b": @123,
                                    @"c": [NSNull null],
                                    @"d": @{},
                                    @"e": @[@"123",@"123132"]};
    NSLog(@"%@",OBJECT_DEBUGER(theDictionary));//Dictionary内的所有对象属性都将打乱
}

- (void)macroDemo {
    NSLog(@"%f",TMO_SYSTEM_VERSION);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
