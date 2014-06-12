//
//  TMOFMDBTests.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-17.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TMOFMDB.h"

@interface TMOFMDBTests : XCTestCase

@end

@implementation TMOFMDBTests

- (void)setUp
{
    [super setUp];
    NSString *tmpDatabase = NSTemporaryDirectory();
    tmpDatabase = [tmpDatabase stringByAppendingString:@"tmoDefault.sqlite"];
    [[NSFileManager defaultManager] removeItemAtPath:tmpDatabase error:nil];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDoubleObject {
    [[TMOFMDB defaultDatabase] inDatabase:^(FMDatabase *db) {
        [db selectWithCallback:^(NSArray *result) {
            [[TMOFMDB defaultDatabase] inDatabase:^(FMDatabase *db) {
                NSArray *newResult = [db selectWithSql:@"select * from sqlite_master"];
            }];
        } withSql:@"select * from sqlite_master"];
    }];
}

- (void)testCreateTable {
    TMOFMDBTableScheme *scheme = [[TMOFMDBTableScheme alloc] init];
    scheme.tableName = @"test";
    scheme.columnScheme =
    @[
      [TMOFMDBColumnScheme schemeWithName:@"id" type:TMOFMDBColumnTypeInteger index:TMOFMDBColumnIndexPrimaryKey],
      [TMOFMDBColumnScheme schemeWithName:@"name" type:TMOFMDBColumnTypeText index:TMOFMDBColumnIndexNone]
      ];
    [[TMOFMDB defaultDatabase] inDatabase:^(FMDatabase *db) {
        [db createTable:scheme];
        [db executeUpdate:@"insert into test values(?,?)", [NSNull null], @"PonyCui"];
    }];
    
    scheme.columnScheme =
    @[
      [TMOFMDBColumnScheme schemeWithName:@"id" type:TMOFMDBColumnTypeInteger index:TMOFMDBColumnIndexPrimaryKey],
      [TMOFMDBColumnScheme schemeWithName:@"testInsert" type:TMOFMDBColumnTypeText index:TMOFMDBColumnIndexNone],
      [TMOFMDBColumnScheme schemeWithName:@"name" type:TMOFMDBColumnTypeText index:TMOFMDBColumnIndexNone]
      ];
    [[TMOFMDB defaultDatabase] inDatabase:^(FMDatabase *db) {
        [db createTable:scheme];
        NSDictionary *result = [db findWithSql:@"select * from test where name = 'PonyCui'"];
        XCTAssertNotNil(result[@"name"], @"PonyCui的记录不应该丢失");
        XCTAssertNotNil(result[@"testInsert"], @"testInsert字段应该在表中，即使它是没有数据在里面的");
    }];
    
    scheme.columnScheme =
    @[
      [TMOFMDBColumnScheme schemeWithName:@"id" type:TMOFMDBColumnTypeInteger index:TMOFMDBColumnIndexPrimaryKey],
      [TMOFMDBColumnScheme schemeWithName:@"name" type:TMOFMDBColumnTypeText index:TMOFMDBColumnIndexNone]
      ];
    
    [[TMOFMDB defaultDatabase] inDatabase:^(FMDatabase *db) {
        [db createTable:scheme];
        NSDictionary *result = [db findWithSql:@"select * from test where name = 'PonyCui'"];
        XCTAssertNotNil(result[@"name"], @"PonyCui的记录不应该丢失");
        XCTAssertNil(result[@"testInsert"], @"testInsert字段不应该在表中，因为它已经被删除了");
    }];
    
}

@end
