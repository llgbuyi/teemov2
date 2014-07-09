//
//  TMOLevelDBManager.m
//  TeemoV2
//
//  Created by 张培创 on 14-4-2.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#define kTMOKVDBCacheDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/com.duowan.kvdb/"]

#import "TMOKVDB.h"
#import <LevelDB.h>
#import "TMOToolKitCore.h"

@interface TMOKVDB ()

@end

@implementation TMOKVDB

+ (NSMutableDictionary *)levelDBCache {
    static NSMutableDictionary *_levelDBCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_levelDBCache) {
            _levelDBCache = [[NSMutableDictionary alloc] init];
        }
    });
    return _levelDBCache;
}

+ (NSString *)realPath:(NSString *)argPath {
    if (argPath == nil || ([argPath isKindOfClass:[NSString class]] && [argPath isEqualToString:@""])) {
        return [kTMOKVDBCacheDirectory stringByAppendingString:@"default"];
    }
    else {
        if ([argPath rangeOfString:@"/"].location == NSNotFound) {
            return [kTMOKVDBCacheDirectory stringByAppendingString:argPath];
        }
        else {
            return argPath;
        }
    }
    return argPath;
}

+ (LevelDB *)dbConnection:(NSString *)realPath {
    LevelDB *db = [[TMOKVDB levelDBCache] objectForKey:realPath];
    if (!db) {
        db = [[LevelDB alloc] initWithPath:realPath andName:@"kvdb"];
        db.encoder = ^ NSData* (LevelDBKey *key, id object) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
            return data;
        };
        db.decoder = ^ id (LevelDBKey *key, NSData * data) {
            id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            return obj;
        };
        if (db) {
            [[TMOKVDB levelDBCache] setObject:db forKey:realPath];
        }
    }
    return db;
}

+ (LevelDB *)defaultDatabase {
    return [TMOKVDB customDatabase:nil];
}

+ (LevelDB *)customDatabase:(NSString *)basePath {
    NSString *realPath = [self realPath:basePath];
    return [self dbConnection:realPath];
}

+ (void)closeAndReleaseSpace:(NSString *)basePath {
    [[NSFileManager defaultManager] removeItemAtPath:[self realPath:basePath] error:nil];
}

+ (long long)sizeOfPath:(NSString *)basePath {
    long long totalSize = 0;
    NSString *realPath = [[self realPath:basePath] stringByAppendingString:@"/"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:realPath];
    for (NSString *itemPath in enumerator) {
        NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:[realPath stringByAppendingString:itemPath] error:nil];
        totalSize += [fileAttr[NSFileSize] integerValue];
    }
    return totalSize;
}

@end

@implementation LevelDB (TMOLevelDB)

+ (NSString *)realCacheKey:(NSString *)fadeKey {
    return [NSString stringWithFormat:@"TMO_Cache_Prefix_%@", fadeKey];
}

- (BOOL)setObject:(id)obj forKey:(NSString *)key cacheTime:(NSTimeInterval)argCacheTime {
    if (obj == nil || key == nil) {
        return NO;
    }
    if (argCacheTime == 0) {
        argCacheTime = NSIntegerMax;
    }
    NSString *realKey = [key stringByMD5Hash];
    BOOL writed = [self setObject:obj forKey:realKey];
    
    NSString *cacheKey = [LevelDB realCacheKey:realKey];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:argCacheTime];
    [self setObject:date forKey:cacheKey];
    
    return writed;
}

- (id)objectWithCacheForKey:(NSString *)key {
    if (arc4random()%100 < 5) {
        [self removeGarbage];
    }
    if (key == nil) {
        return nil;
    }
    NSString *realKey = [key stringByMD5Hash];
    NSString *cacheKey = [LevelDB realCacheKey:realKey];
    NSDate *date = [self objectForKey:cacheKey];
    
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
    if ([date compare:currentDate] != NSOrderedDescending) {
        return nil;
    }
    
    return [self objectForKey:realKey];
}

- (void)removeObjectWithCacheForKey:(NSString *)key {
    if (key == nil) {
        return;
    }
    NSString *realKey = [key stringByMD5Hash];
    [self removeObjectForKey:realKey];
}

#pragma mark -
#pragma mark - KVDB服务机制

- (long long)currentSize {
    NSAssert(NO, @"方法已被废弃，请使用[TMOKVDB sizeOfPath:]");
    return 0;
}

- (void)removeGarbage {
    [self enumerateKeysBackward:YES
                  startingAtKey:nil
            filteredByPredicate:nil
                      andPrefix:[LevelDB realCacheKey:@""]
                     usingBlock:^(LevelDBKey *key, BOOL *stop) {
                         NSString *cacheDateKey = [NSString stringWithUTF8String:key->data];
                         NSDate *expireDate = [self valueForKey:cacheDateKey];
                         NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
                         if ([expireDate compare:currentDate] != NSOrderedDescending) {
                             NSString *realKey = [cacheDateKey stringByReplacingOccurrencesOfString:[LevelDB realCacheKey:@""]
                                                                                         withString:@""];
                             [self removeObjectForKey:cacheDateKey];
                             [self removeObjectForKey:realKey];
                         }
                     }];
}

@end
