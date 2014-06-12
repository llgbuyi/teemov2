//
//  TMOHTTPManagerTests.m
//  TeemoV2
//
//  Created by 张培创 on 14-4-3.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TMOHTTPManager.h"
#import "TMOKVDB.h"

@interface TMOHTTPManagerTests : XCTestCase

@end

@implementation TMOHTTPManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
//    [[TMOHTTPManager shareInstance] cleanAllCache];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[TMOHTTPManager shareInstance] cleanAllCache];
    [super tearDown];
}

- (void)testReachabilityChange
{
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    TMOHTTPManager *manager = [TMOHTTPManager shareInstance];
    [manager setReachabilityStatusChangeBlock:^(TMOReachabilityStatus status) {
        XCTAssert(status == TMOReachabilityStatusWiFi, @"应该是WiFi环境");
    }];
}

@end
