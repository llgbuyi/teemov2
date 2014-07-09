//
//  TMOLevelDBManager.h
//  TeemoV2
//
//  Created by 张培创 on 14-4-2.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LevelDB.h>

extern NSString *const defaultLevelDBName;

@interface LevelDB (TMOLevelDB)

/**
*  存入数据方法（指定秒数后失效）
*
*  @param obj          要求已实现NSCoder协议对象
*  @param key          可根据key获取之前存入对象    - (id)DBObjectForDBKey:(NSString *)key;
*  @param argCacheTime 缓存时间，等于0->无限期，小于0->清除缓存，大于0->N秒后失效
*/
- (BOOL)setObject:(id)obj forKey:(NSString *)key cacheTime:(NSTimeInterval)argCacheTime;

/**
 *  取出数据方法（数据失效时返回nil）
 *
 *  @param key 根据key获取之前存入对象
 *
 *  @return object
 */
- (id)objectWithCacheForKey:(NSString *)key;

/**
 *  删除指定Key数据
 *
 *  @param key TheKey
 */
- (void)removeObjectWithCacheForKey:(NSString *)key;

/**
 *  获取当前数据库占用空间大小
 *  单位：字节
 *  调用示例NSLog(@"%lld",(long long)[kvdb currentSize]);
 *
 *  @return long long
 */
//- (long long)currentSize;//抛弃

/**
 *  将所有过期数据清除
 *  这个方法会有一定概率，默认5%被启动
 */
- (void)removeGarbage;

@end

@interface TMOKVDB : NSObject

/**
 *  获取一个系统默认的数据库
 *  @return 返回LevelDB实例（单例）
 */
+ (LevelDB *)defaultDatabase;

/**
 *  获取一个自定义路径的数据库实例
 *
 *  @param basePath 你可以传入一个英文单词作为标识，这将保存在Library/com.duowan.kvdb目录下，你也可以传入一个路径，这将在你的指定路径下保存数据库信息
 *
 *  @return 返回LevelDB实例（单例）
 */
+ (LevelDB *)customDatabase:(NSString *)basePath;

+ (void)closeAndReleaseSpace:(NSString *)basePath;

+ (long long)sizeOfPath:(NSString *)basePath;

@end
