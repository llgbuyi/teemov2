//
//  TMOKVDBTests.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-3.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TMOKVDB.h"

@interface TMOKVDBTests : XCTestCase

@end

@implementation TMOKVDBTests

- (void)setUp
{
    [super setUp];
    [[TMOKVDB defaultDatabase] removeAllObjects];
}

- (void)tearDown
{
    [TMOKVDB closeAndReleaseSpace:@"default"];
    [super tearDown];
}

- (void)testSetAndGet {
    [[TMOKVDB defaultDatabase] setObject:@"It's a string" forKey:@"stringTest" cacheTime:3];
    NSString *shouldBeAString = [[TMOKVDB defaultDatabase] objectWithCacheForKey:@"stringTest"];
    XCTAssertTrue([shouldBeAString isEqualToString:@"It's a string"], @"存入数据与取出数据应该一致");
    
    NSString *shouldBeNil = [[TMOKVDB defaultDatabase] objectForKey:@"stringTest"];
    XCTAssertNil(shouldBeNil, @"缓存键与非缓存键不应一致，取值应该为空");
    
    [[TMOKVDB defaultDatabase] setObject:@{@"myobj": @"objvalue"} forKey:@"objectTest"];
    NSDictionary *shouldBeAnObject = [[TMOKVDB defaultDatabase] objectForKey:@"objectTest"];
    XCTAssertTrue([shouldBeAnObject isKindOfClass:[NSDictionary class]], @"存入对象，获取后应是对象");
}

- (void)testNil {
    [[TMOKVDB defaultDatabase] setObject:nil forKey:nil cacheTime:0];
    [[TMOKVDB defaultDatabase] objectWithCacheForKey:nil];
}

- (void)testTonsOfDataInsert {
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    for (NSUInteger i=0; i<10000; i++) {
        [[TMOKVDB defaultDatabase] setObject:@"speedTest" forKey:[NSString stringWithFormat:@"%lu",(unsigned long)i]];
    }
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"KVDB更新10,000个键值耗时：%f ms", (endTime - startTime) * 1000);
}

- (void)testCacheExpired {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];
    [[TMOKVDB defaultDatabase] setObject:@"It's a string" forKey:@"expiredTest" cacheTime:1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *shouldBeNil = [[TMOKVDB defaultDatabase] objectWithCacheForKey:@"expiredTest"];
        XCTAssertNil(shouldBeNil, @"10秒后，过期对象读取结果应为空");
        [[TMOKVDB defaultDatabase] removeAllObjects];
        NSString *shouldBeNilAfterRemove = [[TMOKVDB defaultDatabase] objectWithCacheForKey:@"stringTest"];
        XCTAssertNil(shouldBeNilAfterRemove, @"清空数据库后，取值应该为空");
    });
}

@end
