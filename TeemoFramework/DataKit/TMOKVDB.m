//
//  TMOLevelDBManager.m
//  TeemoV2
//
//  Created by 张培创 on 14-4-2.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOKVDB.h"
#import <LevelDB.h>
#import "TMOToolKitCore.h"
#import <sys/stat.h>
#import <dirent.h>

static NSMutableDictionary *dbPool = nil;

@interface TMOKVDB ()

@property (nonatomic, strong) LevelDB *currentDB;

@end

@implementation TMOKVDB

NSString * TMOKVDBPath() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/com.duowan.kvdb/", cachesDir];
}

LevelDB * createConnectionWithPath(NSString *path) {
    LevelDB *db = nil;
    db = [[LevelDB alloc] initWithPath:path andName:@"kvdb"];
    db.encoder = ^ NSData* (LevelDBKey *key, id object) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        return data;
    };
    db.decoder = ^ id (LevelDBKey *key, NSData * data) {
        id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return obj;
    };
    return db;
}

+ (LevelDB *)defaultDatabase {
    return [TMOKVDB customDatabase:[TMOKVDBPath() stringByAppendingString:@"default"]];
}

+ (LevelDB *)customDatabase:(NSString *)basePath {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dbPool = [NSMutableDictionary dictionary];
    });
    if (!dbPool[basePath]) {
        NSString *newPath = basePath;
        if ([newPath rangeOfString:@"/"].location == NSNotFound) {
            newPath = [TMOKVDBPath() stringByAppendingString:basePath];
        }
        dbPool[basePath] = createConnectionWithPath(newPath);
    }
    return dbPool[basePath];
}

+ (void)closeAndReleaseSpace:(NSString *)basePath {
    [self closeDatabase:basePath];
    NSString *thePath = basePath;
    if ([thePath rangeOfString:@"/"].location == NSNotFound) {
        thePath = [TMOKVDBPath() stringByAppendingString:basePath];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:thePath error:&error];
}

+ (void)closeDatabase:(NSString *)basePath {
    [dbPool removeObjectForKey:basePath];
}

@end

@implementation LevelDB (TMOLevelDB)

NSString * getCacheKey_TMO(NSString *key) {
    return [NSString stringWithFormat:@"TMO_Cache_Prefix_%@",key];
}

- (void)setObject:(id)obj forKey:(NSString *)key cacheTime:(NSTimeInterval)argCacheTime {
    if (obj == nil || key == nil) {
        return;
    }
    if (argCacheTime == 0) {
        argCacheTime = NSIntegerMax;
    }
    NSString *realKey = [key stringByMD5Hash];
    [self setObject:obj forKey:realKey];

    NSString *cacheKey = getCacheKey_TMO(realKey);
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:argCacheTime];
    [self setObject:date forKey:cacheKey];
}

- (id)objectWithCacheForKey:(NSString *)key {
    if (arc4random()%100 < 5) {
        [self removeGarbage];
    }
    if (key == nil) {
        return nil;
    }
    NSString *realKey = [key stringByMD5Hash];
    NSString *cacheKey = getCacheKey_TMO(realKey);
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
    return [self cacheFolderSize:[self.path cStringUsingEncoding:NSUTF8StringEncoding]];
}

- (long long) cacheFolderSize:(const char *)folderPath{
    if (folderPath == nil) {
        folderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] cStringUsingEncoding:NSUTF8StringEncoding];
    }
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        int folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self cacheFolderSize:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }
    }
    return folderSize;
}

- (void)removeGarbage {
    [self enumerateKeysBackward:YES startingAtKey:nil filteredByPredicate:nil andPrefix:getCacheKey_TMO(@"") usingBlock:^(LevelDBKey *key, BOOL *stop) {
        NSString *cacheDateKey = [NSString stringWithUTF8String:key->data];
        NSDate *expireDate = [self valueForKey:cacheDateKey];
        NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
        if ([expireDate compare:currentDate] != NSOrderedDescending) {
            NSString *realKey = [cacheDateKey stringByReplacingOccurrencesOfString:getCacheKey_TMO(@"") withString:@""];
            [self removeObjectForKey:cacheDateKey];
            [self removeObjectForKey:realKey];
        }
    }];
}

@end
