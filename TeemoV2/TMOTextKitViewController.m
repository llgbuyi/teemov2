//
//  TMOTextKitViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-23.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOTextKitViewController.h"
#import "TMOUIKitCore.h"

@interface TMOTextKitViewController ()<NIAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet NIAttributedLabel *label;

@end

@implementation TMOTextKitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"PonyTextKit";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NIAttributedLabel instance];
    
    [NIAttributedLabel addStyleAttributed:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0]} tagName:@"$default"];
    
    [NIAttributedLabel addStyleBlock:^(TTTagItem *tagItem, NSMutableAttributedString *theString) {
        [theString addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18.0],
                                   NSForegroundColorAttributeName: [UIColor redColor]}
                           range:tagItem.range];
    } tagName:@"mayun"];
    
    NSString *myTagString = @"【<mayun>马云</mayun>足球算什么<image width=20 height=20 src=http://comment3.duowan.com/img/icon_expression.png> </image>？<mayun>马云</mayun>欲推未来医院计划 】据上海政府网披露，支付宝钱包目前正与上海多家大型医院洽谈合作，有望对接医保系统。市民可以用手机挂号、支付宝付费，到医院直接就诊。目前该功能已在新华医院试点。支付宝对接医院后，将颠覆患者以往单调的就医模式。<link href=http://t.cn/Rvxuwxz>【打开链接】</link>【<mayun>马云</mayun>足球算什么<image width=20 height=20 src=http://comment3.duowan.com/img/icon_expression.png> </image>？<mayun>马云</mayun>欲推未来医院计划 】据上海政府网披露，支付宝钱包目前正与上海多家大型医院洽谈合作，有<space width=1 height=50> </space>望对接医保系统。市民可以用手机挂号、支付宝付费，到医院直接就诊。目前该功能已在新华医院试点。支付宝对接医院后，将颠覆患者以往单调的就医模式。<link href=http://t.cn/Rvxuwxz>【打开链接】</link>【<mayun>马云</mayun>足球算什么<image width=20 height=20 src=http://comment3.duowan.com/img/icon_expression.png> </image>？<mayun>马云</mayun>欲推未来医院计划 】据上海政府网披露，支付宝钱包目前正与上海多家大型医院洽谈合作，有望对接医保系统。市民可以用手机挂号、支付宝付费，到医院直接就诊。目前该功能已在新华医院试点。支付宝对接医院后，将颠覆患者以往单调的就医模式。<link href=http://t.cn/Rvxuwxz>【打开链接】</link>";
    
    NSMutableAttributedString *attr = [NIAttributedLabel attributedStringWithTagString:myTagString];
    
    [self.label setDelegate:self];
    [self.label setAttributedText:[attr copy]];
    [self.label addLinks];
    [self.label addImages];
    
    CGRect rect = self.label.frame;
    rect.size.height = NISizeOfAttributedStringConstrainedToSize(attr, CGSizeMake(rect.size.width, CGFLOAT_MAX), 0).height;
    [self.label setFrame:rect];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    [[UIApplication sharedApplication] openURL:result.URL];
}

@end
