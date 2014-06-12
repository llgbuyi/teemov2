//
//  TMOFMDB.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-2.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//
//  线程安全 Sqlite

#import "TMOFMDB.h"

@implementation TMOFMDBTableScheme

@end

@implementation TMOFMDBColumnScheme

+ (TMOFMDBColumnScheme *)schemeWithName:(NSString *)argName
                                   type:(TMOFMDBColumnType)argType
                                  index:(TMOFMDBColumnIndex)argIndex {
    TMOFMDBColumnScheme *scheme = [[TMOFMDBColumnScheme alloc] init];
    scheme.columnName = argName;
    scheme.columnType = argType;
    scheme.columnIndex = argIndex;
    return scheme;
}

@end

@implementation FMDatabase (TMOFMDatabase)

- (void)createTable:(TMOFMDBTableScheme *)argScheme {
    
    NSString *createTableSQL = [self createTableSql:argScheme];
    
    NSDictionary *existTable = [self findWithSql:@"select * from sqlite_master where type='table' and name=?",
                                argScheme.tableName];
    if (existTable == nil) {
        [self executeUpdate:createTableSQL];
    }
    else if (![existTable[@"sql"] isEqualToString:createTableSQL]) {
        [self executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO tmp_%@",
                             argScheme.tableName,
                             argScheme.tableName]];
        [self executeUpdate:createTableSQL];
        NSArray *allData = [self selectWithSql:[NSString stringWithFormat:@"SELECT * FROM tmp_%@", argScheme.tableName]];
        NSString *insertSql = [self insertSql:argScheme];
        for (NSDictionary *dataItem in allData) {
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
            for (TMOFMDBColumnScheme *columnItem in argScheme.columnScheme) {
                if (dataItem[columnItem.columnName] == nil) {
                    [dataDictionary setObject:@"" forKey:columnItem.columnName];
                }
                else {
                    [dataDictionary setObject:dataItem[columnItem.columnName] forKey:columnItem.columnName];
                }
            }
            [self executeUpdate:insertSql withParameterDictionary:dataDictionary];
        }
        [self executeUpdate:[NSString stringWithFormat:@"DROP TABLE tmp_%@",argScheme.tableName]];
    }
}

- (NSString *)createTableSql:(TMOFMDBTableScheme *)argScheme {
    NSString *createTableSQL = @"";
    NSMutableArray *createColumnSQL = [NSMutableArray array];
    for (TMOFMDBColumnScheme *columnItem in argScheme.columnScheme) {
        NSString *typeString;
        if (columnItem.columnType == TMOFMDBColumnTypeInteger) {
            typeString = @" INTEGER";
        }
        else if (columnItem.columnType == TMOFMDBColumnTypeText) {
            typeString = @" TEXT";
        }
        else if (columnItem.columnType == TMOFMDBColumnTypeReal) {
            typeString = @" REAL";
        }
        else if (columnItem.columnType == TMOFMDBColumnTypeBLOB) {
            typeString = @" BLOB";
        }
        else if (columnItem.columnType == TMOFMDBColumnTypeNull) {
            typeString = @" NULL";
        }
        NSString *indexString = @"";
        if (columnItem.columnIndex == TMOFMDBColumnIndexPrimaryKey) {
            indexString = @" PRIMARY KEY";
        }
        else if (columnItem.columnIndex == TMOFMDBColumnIndexUnique) {
            indexString = @" UNIQUE";
        }
        [createColumnSQL addObject:[NSString stringWithFormat:@"%@%@%@",
                                    columnItem.columnName,
                                    typeString,
                                    indexString]];
    }
    createTableSQL = [NSString stringWithFormat:@"CREATE TABLE %@ (%@)",
                      argScheme.tableName,
                      [createColumnSQL componentsJoinedByString:@","]];
    return createTableSQL;
}

- (NSString *)insertSql:(TMOFMDBTableScheme *)argScheme {
    NSMutableArray *columnString = [NSMutableArray array];
    for (TMOFMDBColumnScheme *columnItem in argScheme.columnScheme) {
        [columnString addObject:[NSString stringWithFormat:@":%@", columnItem.columnName]];
    }
    return [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ (%@) VALUES (%@)",
            argScheme.tableName,
            [[columnString componentsJoinedByString:@","] stringByReplacingOccurrencesOfString:@":" withString:@""],
            [columnString componentsJoinedByString:@","]];
}

/**
 * 所有select方法都依赖此方法
 **/
- (NSArray *)selectWithSql:(NSString *)argSql withVAList:(va_list)args {
    NSMutableArray *resultArray = [NSMutableArray array];
    FMResultSet *rs = [self executeQuery:argSql withVAList:args];
    while ([rs next]) {
        [resultArray addObject:[rs resultDictionary]];
    }
    return [resultArray copy];
}

- (NSArray *)selectWithSql:(NSString *)argSql,... {
    va_list args;
    va_start(args, argSql);
    NSArray *result = [self selectWithSql:argSql withVAList:args];
    va_end(args);
    return [result copy];
}

- (NSDictionary *)findWithSql:(NSString *)argSql,... {
    va_list args;
    va_start(args, argSql);
    NSArray *result = [self selectWithSql:argSql withVAList:args];
    va_end(args);
    if (result != nil && [result count] > 0) {
        return [result firstObject];
    }
    else {
        return nil;
    }
}

- (void)selectWithCallback:(void (^)(NSArray *))argCallback withSql:(NSString *)argSql, ...{
    va_list args;
    va_start(args, argSql);
    NSArray *result = [self selectWithSql:argSql withVAList:args];
    va_end(args);
    if (argCallback != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            argCallback(result);
        });
    }
}

- (void)selectWithCallbackOnQueryThread:(void (^)(NSArray *result, FMDatabase *db))argCallback
                                withSql:(NSString *)argSql, ... {
    va_list args;
    va_start(args, argSql);
    NSArray *result = [self selectWithSql:argSql withVAList:args];
    va_end(args);
    if (argCallback != nil) {
        argCallback(result, self);
    }
}

- (void)findWithCallback:(void (^)(NSDictionary *))argCallback withSql:(NSString *)argSql, ... {
    va_list args;
    va_start(args, argSql);
    NSArray *result = [self selectWithSql:argSql withVAList:args];
    va_end(args);
    if (argCallback != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result != nil && [result count] > 0) {
                argCallback([result firstObject]);
            }
            else {
                argCallback(nil);
            }
        });
    }
}

- (void)findWithCallbackOnQueryThread:(void (^)(NSDictionary *result, FMDatabase *db))argCallback
                              withSql:(NSString *)argSql, ... {
    va_list args;
    va_start(args, argSql);
    NSArray *result = [self selectWithSql:argSql withVAList:args];
    va_end(args);
    if (argCallback != nil) {
        if (result != nil && [result count] > 0) {
            argCallback([result firstObject], self);
        }
        else {
            argCallback(nil, self);
        }
    }
}

@end

@interface TMODatabaseQueue (){
    dispatch_queue_t _async_queue;
}

@property (strong, nonatomic) NSDictionary *queueBlock;

@end

@implementation TMODatabaseQueue

- (void)inDatabase:(void (^)(FMDatabase *db))block {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _async_queue = dispatch_queue_create([[NSString stringWithFormat:@"tmodb.%@", self] UTF8String], NULL);
    });
    dispatch_async(_async_queue, ^{
        [super inDatabase:block];
    });
}

- (void)inDatabaseRunOnMainThread:(void (^)(FMDatabase *))block {
    [super inDatabase:block];
}

@end

@implementation TMOFMDB

/**
 * 返回指定数据库实例单例
 **/
+ (TMODatabaseQueue *)instanceWithPath:(NSString *)argPath {
    static NSMutableDictionary *pool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [NSMutableDictionary dictionary];
    });
    if (pool[argPath] == nil) {
        NSString *newPath = argPath;
        if ([argPath rangeOfString:@"/var"].location > 0 && [argPath rangeOfString:@"/Users"].location > 0) {
            NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByReplacingOccurrencesOfString:[[[NSBundle mainBundle] bundlePath] lastPathComponent] withString:@""];
            newPath = [bundlePath stringByAppendingString:argPath];//补全包地址
        }
        TMODatabaseQueue *queueObject = [TMODatabaseQueue databaseQueueWithPath:newPath];
        if (queueObject != nil) {
            [pool setObject:queueObject forKey:argPath];
        }
    }
    return pool[argPath];
}

+ (TMODatabaseQueue *)defaultDatabase {
    return [TMOFMDB instanceWithPath:@"tmp/tmoDefault.sqlite"];
}

@end
