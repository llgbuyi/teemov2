//
//  TMORequestFetcher.h
//  TeemoV2
//
//  Created by 张培创 on 14-3-31.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMOHTTPResult.h"
#import "GTMHTTPFetcher.h"

@class GTMHTTPFetcherService;
@class Reachability;
@class LevelDB;

extern NSString * const kTMONetworkCacheDatabaseKey;

/**
 *  请求优先级
 */
typedef enum {
    /**
     *  信令请求优先级，最高优先级
     */
    TMOFetcherPriorityHigh = -1,
    /**
     *  小数据量请求优先级
     */
    TMOFetcherPriorityNormal,
    /**
     *  小数据量请求优先级
     */
    TMOFetcherPriorityLow
}TMOFetcherPriority;

/**
 *  网络状态
 */
typedef enum {
    /**
     *  无网络
     */
    TMOReachabilityStatusNoNetWork,
    /**
     *  WiFi
     */
    TMOReachabilityStatusWiFi,
    /**
     *  2g/3g网络
     */
    TMOReachabilityStatusWWAN
}TMOReachabilityStatus;

/**
 *  HTTP封装
 */
@interface TMOHTTPManager : NSObject {
    NSOperationQueue *_globalQueue;
    NSOperationQueue *_downloadQueue;
    GTMHTTPFetcherService *_fetcherService;
    GTMHTTPFetcherService *_downloadService;
    Reachability *_fetcherReachability;
}

/**
 *  您应该始终使用[TMOHTTPManager shareInstance]，而不应自行初始化对象
 *
 *  @return nil;
 */
- (id)init;

/**
 *  获取网络状态
 */
@property (nonatomic) TMOReachabilityStatus reachabilityStatus;

/**
 *  判断当前网络是否可用
 */
@property (nonatomic, readonly) BOOL isNetWorkOK;

/**
 *  为指定域名绑定IP
 *  你只应该在开发环境下使用此方法
 *  如果要在生产环境下使用此方法，请确定域名所对应的IP应具备绝对稳定性
 *
 *  Value -> IP
 *  Key   -> 域名
 */
@property (nonatomic, strong) NSDictionary *hostDictionary;

/**
 *  设置网络状态变化回调
 *
 *  @param block 回调块
 */
- (void)setReachabilityStatusChangeBlock:(void (^)(TMOReachabilityStatus status))block;

/**
 *  异步获取网络状态
 *
 *  @param argCallback 回调块
 */
- (void)networkStatus:(void (^)(TMOReachabilityStatus))argCallback;

/**
 *  单例实例化方法
 *
 *  @return HTTP请求单例
 */
+ (TMOHTTPManager *)shareInstance;

/**
 *  发起一个异步GET请求；
 *  2G3G网络超时60秒，WIFI超时10秒；
 *  无任何缓存，一般优先级。
 *
 *  @param argURL   GET请求的URL
 *  @param argBlock 请求完成回调块
 */
+ (void)simpleGet:(NSString *)argURL
  completionBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock;

/**
 *  发起一步异步POST请求；
 *  超时时间统一为60秒；
 *
 *  @param argURL      POST请求的URL
 *  @param argPostInfo POST请求的参数，NSDictionary
 *  @param argBlock    请求完成回调块
 */
+ (void)simplePost:(NSString *)argURL
          postInfo:(NSDictionary *)argPostInfo
   completionBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock;

/**
 *  发起异步请求
 *
 *  @param argURL             请求URL
 *  @param argPostInfo        post请求时请求体内容(NSDictionary)，若为get请求，直接传nil
 *  @param argTimeoutInterval 超时时间
 *  @param argHeaders         post请求时请求头内容，若为get请求，直接传nil
 *  @param argOwner           请求持有者
 *  @param argCacheTime       缓存时间，缓存时间等于0，表示缓存无限期，小于0表示缓存立即失效
 *  @param argPriority        请求优先级
 *  @param argHandle          SEL回调方法     格式：- (void)fetchCompletionWithData:(TMOHTTPResult *)data WithError:(NSError *)error
 *  @param argBlock           block回调方法
 */
- (GTMHTTPFetcher *)fetchWithURL:(NSString *)argURL
            postInfo:(NSDictionary *)argPostInfo
     timeoutInterval:(NSTimeInterval)argTimeoutInterval
             headers:(NSDictionary *)argHeaders
               owner:(id)argOwner
           cacheTime:(NSTimeInterval)argCacheTime
     fetcherPriority:(TMOFetcherPriority)argPriority
     comletionHandle:(SEL)argHandle
     completionBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock;

/**
 *  发起异步请求 方法2
 *
 *  @param argURL             请求URL
 *  @param argPostData        post请求时请求体内容(NSData)，若为get请求，直接传nil
 *  @param argTimeoutInterval 超时时间
 *  @param argHeaders         post请求时请求头内容，若为get请求，直接传nil
 *  @param argOwner           请求持有者
 *  @param argCacheTime       缓存时间
 *  @param argPriority        请求优先级
 *  @param argHandle          SEL回调方法     格式：- (void)fetchCompletionWithData:(TMOHTTPResult *)data WithError:(NSError *)error
 *  @param argBlock           block回调方法
 */
- (GTMHTTPFetcher *)fetchWithURL:(NSString *)argURL
            postData:(NSData *)argPostData
     timeoutInterval:(NSTimeInterval)argTimeoutInterval
             headers:(NSDictionary *)argHeaders
               owner:(id)argOwner
           cacheTime:(NSTimeInterval)argCacheTime
     fetcherPriority:(TMOFetcherPriority)argPriority
     comletionHandle:(SEL)argHandle
     completionBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock;

/**
 *  发起下载异步请求
 *
 *  @param argURL             请求URL
 *  @param argPostInfo        post请求时请求体内容，若为get请求，直接传nil
 *  @param argTimeoutInterval 超时时间
 *  @param argHeaders         post请求时请求头内容，若为get请求，直接传nil
 *  @param argOwner           请求持有者
 *  @param argPath            下载路径（文件将保存在这里）
 *  @param argReceiveBlock    返回当前已下载长度和总长度 byte
 *  @param argHandle          SEL回调方法     格式：-
 *  @param argBlock           block回调方法   返回是否成功完整下载并写入文件
 */
- (void)downloadWithURL:(NSString *)argURL
               postInfo:(NSDictionary *)argPostInfo
        timeoutInterval:(NSTimeInterval)argTimeoutInterval
                headers:(NSDictionary *)argHeaders
                  owner:(id)argOwner
                   path:(NSString *)argPath
 receiveDataLengthBlock:(void (^)(NSUInteger currentLength, NSUInteger totalLength))argReceiveBlock
 completeDownloadHandle:(SEL)argHandle
  completeDownloadBlock:(void (^)(NSError *error))argBlock;

/**
 *  发起上传异步请求
 *
 *  @param argURL             请求URL
 *  @param argPostInfo        post请求时请求体内容
 *  @param argTimeoutInterval 超时时间
 *  @param argHeaders         post请求时请求头内容
 *  @param argOwner           请求持有者
 *  @param argKey             Form上传键
 *  @param argName            待上传文件的文件名
 *  @param argPath            待上传文件的路径
 *  @param argReceiveBlock    上传进度回调块
 *  @param argHandle          上传完成SEL回调 格式：- (void)fetchCompletionWithData:(TMOHTTPResult *)data WithError:(NSError *)error
 *  @param argBlock           上传守成block回调
 */
- (void)uploadWithURL:(NSString *)argURL
             postInfo:(NSDictionary *)argPostInfo
      timeoutInterval:(NSTimeInterval)argTimeoutInterval
              headers:(NSDictionary *)argHeaders
                owner:(id)argOwner
              fileKey:(NSString *)argKey
             fileName:(NSString *)argName
                 path:(NSString *)argPath
  sendDataLengthBlock:(void (^)(NSUInteger currentLength, NSUInteger totalLength))argReceiveBlock
completeUploadHandle:(SEL)argHandle
completeUploadBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock;

/**
 *  获取一个可供自定义的fetcher
 *
 *  @param argURL 需要抓取的URL
 *
 *  @return 返回GTMHTTPFetcher实例
 */
- (GTMHTTPFetcher *)getCustomFetcherWithURL:(NSString *)argURL;

/**
 *  使用getCustomFetcherWithURL:并设置好自己的请求参数后，使用此方法执行查询
 *
 *  @param argFetcher 传入GTMHTTPFetcher实例
 *  @param argOwner   请求持有者
 *  @param argTime    缓存时间
 *  @param argHandle  SEL回调
 *  @param argBlock   回调块
 */
- (void)beginWithCustomFetcher:(GTMHTTPFetcher *)argFetcher
                         owner:(id)argOwner
                     cacheTime:(NSTimeInterval)argTime
               comletionHandle:(SEL)argHandle
               completionBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock;

/**
 *  取消某个URL的请求
 *
 *  @param argURL URL
 */
- (void)cancelFetcherWithURL:(NSString *)argURL;

/**
 *  取消上传和下载请求
 */
- (void)cancelDownloadAndUploadFetcher;

/**
 *  取消除高优先级（信令）以外的所有请求
 */
- (void)cancelOnlyExceptHighPriorityFetcher;

/**
 *  取消所有请求
 */
- (void)cancelAllFetcher;

/**
 *  获取当前网络缓存仓库的大小
 *
 *  @return long long
 */
- (long long)cacheSize;

/**
 *  清除所有网络缓存
 *  此方法会释放所有空间
 */
- (void)cleanAllCache;

/**
 *  清除过期缓存
 *  注意：清除过期缓存并不会释放空间
 */
- (void)cleanExpiredCache;

@end
