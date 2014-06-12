//
//  TMORequestFetcher.m
//  TeemoV2
//
//  Created by 张培创 on 14-3-31.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOHTTPManager.h"
#import "GTMHTTPFetcherService.h"
#import "Reachability.h"
#import "TMOKVDB.h"
#import <GTMHTTPUploadFetcher.h>

NSString * const kTMONetworkCacheDatabaseKey = @"networkCache";

typedef void (^TMOReachabilityStatusBlock)(TMOReachabilityStatus status);

@interface TMOHTTPManager ()

@property (readwrite, nonatomic, copy) TMOReachabilityStatusBlock reachabilityStatusBlock;

@property (nonatomic, weak) LevelDB *cacheDatabase;

@end

@implementation TMOHTTPManager

+ (TMOHTTPManager *)shareInstance {
    static TMOHTTPManager *fetcher = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        fetcher = [[TMOHTTPManager alloc] _init];
    });
    return fetcher;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  不允许用户自行创建实例，应该始终使用单例
 *
 *  @return nil
 */
- (id)init {
    NSAssert(NO, @"您应该始终使用[TMOHTTPManager shareInstance]，而不应自行初始化对象");
    return nil;
}

- (id)_init {
    if (self = [super init]) {
        _globalQueue = [[NSOperationQueue alloc] init];
        _downloadQueue = [[NSOperationQueue alloc] init];
        _fetcherService = [[GTMHTTPFetcherService alloc] init];
        _downloadService = [[GTMHTTPFetcherService alloc] init];
        _fetcherService.maxRunningFetchersPerHost = 10;
        _fetcherReachability = [Reachability reachabilityWithHostname:@"www.baidu.com"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        [_fetcherReachability startNotifier];
    }
    return self;
}

- (LevelDB *)cacheDatabase {
    if (_cacheDatabase == nil) {
        _cacheDatabase = [TMOKVDB customDatabase:kTMONetworkCacheDatabaseKey];
    }
    return _cacheDatabase;
}

#pragma mark - Fetcher

+ (void)simpleGet:(NSString *)argURL completionBlock:(void (^)(TMOHTTPResult *, NSError *))argBlock {
    TMOHTTPManager *manager = [self shareInstance];
    [manager fetchWithURL:argURL
                 postInfo:nil
          timeoutInterval:(manager.reachabilityStatus == TMOReachabilityStatusWWAN ? 60 : 10)
                  headers:nil
                    owner:nil
                cacheTime:-1
          fetcherPriority:TMOFetcherPriorityNormal
          comletionHandle:nil
          completionBlock:argBlock];
}

+ (void)simplePost:(NSString *)argURL
          postInfo:(NSDictionary *)argPostInfo
   completionBlock:(void (^)(TMOHTTPResult *, NSError *))argBlock {
    TMOHTTPManager *manager = [self shareInstance];
    [manager fetchWithURL:argURL
                 postInfo:argPostInfo
          timeoutInterval:60
                  headers:nil
                    owner:nil
                cacheTime:-1
          fetcherPriority:TMOFetcherPriorityNormal
          comletionHandle:nil
          completionBlock:argBlock];
}

- (GTMHTTPFetcher *)fetchWithURL:(NSString *)argURL
            postInfo:(NSDictionary *)argPostInfo
     timeoutInterval:(NSTimeInterval)argTimeoutInterval
             headers:(NSDictionary *)argHeaders
               owner:(id)argOwner
           cacheTime:(NSTimeInterval)argCacheTime
     fetcherPriority:(TMOFetcherPriority)argPriority
     comletionHandle:(SEL)argHandle
     completionBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock {
    
    GTMHTTPFetcher *fetcher = [self getCustomFetcherWithURL:argURL];
    [fetcher setServicePriority:argPriority];
    [fetcher.mutableRequest setTimeoutInterval:argTimeoutInterval];
    
    NSString *postInfoStr = nil;
    if (argPostInfo) {
        NSMutableArray *tempArray = [NSMutableArray array];
        //采用block枚举来遍历字典
        [argPostInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            NSString *temp = [NSString stringWithFormat:@"%@=%@",key,obj];
            [tempArray addObject:temp];
        }];
        postInfoStr = [tempArray componentsJoinedByString:@"&"];
        fetcher.postData = [postInfoStr dataUsingEncoding:NSUTF8StringEncoding];
        [fetcher.mutableRequest setAllHTTPHeaderFields:argHeaders];
        if(![fetcher.mutableRequest valueForHTTPHeaderField:@"Content-Type"]){
            NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            [fetcher.mutableRequest setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        }
    }
    [self beginWithCustomFetcher:fetcher owner:argOwner cacheTime:argCacheTime comletionHandle:argHandle completionBlock:argBlock];
    return fetcher;
}

- (GTMHTTPFetcher *)fetchWithURL:(NSString *)argURL
            postData:(NSData *)argPostData
     timeoutInterval:(NSTimeInterval)argTimeoutInterval
             headers:(NSDictionary *)argHeaders
               owner:(id)argOwner
           cacheTime:(NSTimeInterval)argCacheTime
     fetcherPriority:(TMOFetcherPriority)argPriority
     comletionHandle:(SEL)argHandle
     completionBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock {
    
    GTMHTTPFetcher *fetcher = [self getCustomFetcherWithURL:argURL];
    [fetcher setServicePriority:argPriority];
    [fetcher.mutableRequest setTimeoutInterval:argTimeoutInterval];
    
    if (argPostData) {
        fetcher.postData = argPostData;
        [fetcher.mutableRequest setAllHTTPHeaderFields:argHeaders];
        if(![fetcher.mutableRequest valueForHTTPHeaderField:@"Content-Type"]){
            NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            [fetcher.mutableRequest setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        }
    }
    [self beginWithCustomFetcher:fetcher owner:argOwner cacheTime:argCacheTime comletionHandle:argHandle completionBlock:argBlock];
    return fetcher;
}

- (void)downloadWithURL:(NSString *)argURL
               postInfo:(NSDictionary *)argPostInfo
        timeoutInterval:(NSTimeInterval)argTimeoutInterval
                headers:(NSDictionary *)argHeaders
                  owner:(id)argOwner
                   path:(NSString *)argPath
 receiveDataLengthBlock:(void (^)(NSUInteger currentLength, NSUInteger totalLength))argReceiveBlock
 completeDownloadHandle:(SEL)argHandle
  completeDownloadBlock:(void (^)(NSError *error))argBlock {
    
    NSData *downloadData = [NSData dataWithContentsOfFile:argPath];
    NSUInteger previousLength = downloadData.length;
    
    GTMHTTPFetcher *fetcher = [self getDownloadFetcherWithURL:argURL];
    fetcher.downloadPath = argPath;
    [fetcher.mutableRequest setTimeoutInterval:argTimeoutInterval];
    NSString *postInfoStr = nil;
    if (argPostInfo) {
        NSMutableArray *tempArray = [NSMutableArray array];
        //采用block枚举来遍历字典
        [argPostInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            NSString *temp = [NSString stringWithFormat:@"%@=%@",key,obj];
            [tempArray addObject:temp];
        }];
        postInfoStr = [tempArray componentsJoinedByString:@"&"];
        fetcher.postData = [postInfoStr dataUsingEncoding:NSUTF8StringEncoding];
        [fetcher.mutableRequest setAllHTTPHeaderFields:argHeaders];
        if(![fetcher.mutableRequest valueForHTTPHeaderField:@"Content-Type"]){
            NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            [fetcher.mutableRequest setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        }
    }
    [fetcher.mutableRequest setValue:[NSString stringWithFormat:@"bytes=%lu-",(unsigned long)previousLength] forHTTPHeaderField:@"range"];
    [self beginWithDownloadFetcher:fetcher previousLength:previousLength owner:argOwner receiveDataLengthBlock:argReceiveBlock completeDownloadHandle:argHandle completeDownloadBlock:argBlock];
}

- (void)uploadWithURL:(NSString *)argURL
             postInfo:(NSDictionary *)argPostInfo
      timeoutInterval:(NSTimeInterval)argTimeoutInterval
              headers:(NSDictionary *)argHeaders
                owner:(id)argOwner
              fileKey:(NSString *)argKey
             fileName:(NSString *)argName
                 path:(NSString *)argPath
  sendDataLengthBlock:(void (^)(NSUInteger currentLength, NSUInteger totalLength))argSendBlock
completeUploadHandle:(SEL)argHandle
completeUploadBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock {
    NSData *uploadData = [NSData dataWithContentsOfFile:argPath];
    GTMHTTPFetcher *fetcher = [self getDownloadFetcherWithURL:argURL];
    
    [fetcher.mutableRequest setTimeoutInterval:argTimeoutInterval];
    [fetcher.mutableRequest setValue:@"duowan app" forHTTPHeaderField:@"User-Agent"];
    [fetcher.mutableRequest setAllHTTPHeaderFields:argHeaders];
    
    NSString *boundary = @"0xLhTaLbOkNdArZ";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [fetcher.mutableRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    
    if (argPostInfo != nil) {
        [argPostInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@",obj] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }];
    }
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", argKey, argName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:uploadData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [fetcher setPostData:body];
    
    [self beginWithUploadFetcher:fetcher owner:argOwner sendDataLengthBlock:argSendBlock completeUploadHandle:argHandle completeUploadBlock:argBlock];
}

- (GTMHTTPFetcher *)getCustomFetcherWithURL:(NSString *)argURL {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:argURL]];
    GTMHTTPFetcher *fetcher = [_fetcherService fetcherWithRequest:request];
    [fetcher setDelegateQueue:_globalQueue];
    return fetcher;
}

- (GTMHTTPFetcher *)getDownloadFetcherWithURL:(NSString *)argURL {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:argURL]];
    GTMHTTPFetcher *fetcher = [_downloadService fetcherWithRequest:request];
    [fetcher setDelegateQueue:_globalQueue];
    return fetcher;
}

- (void)beginWithCustomFetcher:(GTMHTTPFetcher *)argFetcher
                         owner:(id)argOwner
                     cacheTime:(NSTimeInterval)argCacheTime
               comletionHandle:(SEL)argHandle
               completionBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock {
    NSData *cacheData;
    if (argCacheTime >= 0 &&
        (cacheData = [self.cacheDatabase objectWithCacheForKey:argFetcher.mutableRequest.URL.absoluteString])) {    //判断是否存在缓存
        TMOHTTPResult *result = [TMOHTTPResult createHTTPResultWithRequest:argFetcher.mutableRequest WithResponse:argFetcher.response WithData:cacheData];
        if (argBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                argBlock(result, nil);
            });
        }
        if (argOwner && argHandle) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //由于performSelector方法有可能出现内存泄露，所以使用下列语句替换
                IMP imp = [argOwner methodForSelector:argHandle];
                void (*func)(id, SEL, TMOHTTPResult *, NSError *) = (void *)imp;
                func(argOwner, argHandle, result, nil);
            });
        }
    } else {
        GTMHTTPFetcher __weak *fet = argFetcher;
        if (self.hostDictionary != nil) {
            fet.mutableRequest = [self addHostToRequest:fet.mutableRequest];
        }
        [argFetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            TMOHTTPResult *result = [TMOHTTPResult createHTTPResultWithRequest:fet.mutableRequest WithResponse:fet.response WithData:data];
            dispatch_queue_t myDispatchQueue = dispatch_get_main_queue();
            dispatch_async(myDispatchQueue, ^{
                if (data && [fet.mutableRequest.HTTPMethod isEqualToString:@"GET"]) {
                    if (argCacheTime < 0) {
                        [self.cacheDatabase removeObjectWithCacheForKey:fet.mutableRequest.URL.absoluteString];//缓存时间小于0表明需要清除缓存
                    }
                    else {
                        [self.cacheDatabase setObject:data
                                               forKey:fet.mutableRequest.URL.absoluteString
                                            cacheTime:argCacheTime];
                    }
                }
                if (argBlock) {
                    argBlock(result, error);
                }
                if (argOwner && argHandle) {
                    //由于performSelector方法有可能出现内存泄露，所以使用下列语句替换
                    IMP imp = [argOwner methodForSelector:argHandle];
                    void (*func)(id, SEL, TMOHTTPResult *, NSError *) = (void *)imp;
                    func(argOwner, argHandle, result, error);
                }
            });
        }];
    }
}

- (NSMutableURLRequest *)addHostToRequest:(NSMutableURLRequest *)argRequest {
    if (self.hostDictionary[argRequest.URL.host] != nil) {
        NSString *URLString = argRequest.URL.absoluteString;
        URLString = [URLString stringByReplacingOccurrencesOfString:argRequest.URL.host withString:self.hostDictionary[argRequest.URL.host]];
        NSMutableDictionary *HTTPHeaderDictionary = [argRequest.allHTTPHeaderFields mutableCopy];
        if (HTTPHeaderDictionary == nil) {
            HTTPHeaderDictionary = [NSMutableDictionary dictionary];
        }
        [HTTPHeaderDictionary setObject:argRequest.URL.host forKey:@"Host"];
        [argRequest setURL:[NSURL URLWithString:URLString]];
        [argRequest setAllHTTPHeaderFields:HTTPHeaderDictionary];
    }
    return argRequest;
}

- (void)cancelFetcherWithURL:(NSString *)argURL {
    NSURL *url = [NSURL URLWithString:argURL];
    if (self.hostDictionary[url.host] != nil) {
        //Host绑定
        NSString *URLString = url.absoluteString;
        URLString = [URLString stringByReplacingOccurrencesOfString:url.host withString:self.hostDictionary[url.host]];
        url = [NSURL URLWithString:URLString];
    }
    NSArray *fetchers = [_fetcherService issuedFetchersWithRequestURL:url];
    [fetchers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GTMHTTPFetcher *fet = (GTMHTTPFetcher *)obj;
        [fet stopFetching];
    }];
    NSArray *fetchersForDownload = [_downloadService issuedFetchersWithRequestURL:url];
    [fetchersForDownload enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GTMHTTPFetcher *fet = (GTMHTTPFetcher *)obj;
        [fet stopFetching];
    }];
}

- (void)cancelDownloadAndUploadFetcher {
    [_downloadService stopAllFetchers];
}

- (void)cancelOnlyExceptHighPriorityFetcher {
    [self cancelDownloadAndUploadFetcher];
    NSArray *runningFetchers = [_fetcherService.runningHosts allValues];
    NSArray *delayFetchers = [_fetcherService.delayedHosts allValues];
    [runningFetchers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *array = (NSArray *)obj;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GTMHTTPFetcher *fetcher = (GTMHTTPFetcher *)obj;
            if (fetcher.servicePriority >= 0) {
                [fetcher stopFetching];
            }
        }];
    }];
    [delayFetchers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *array = (NSArray *)obj;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GTMHTTPFetcher *fetcher = (GTMHTTPFetcher *)obj;
            if (fetcher.servicePriority >= 0) {
                [fetcher stopFetching];
            }
        }];
    }];
}

- (void)cancelAllFetcher {
    [self cancelDownloadAndUploadFetcher];
    [_fetcherService stopAllFetchers];
}

- (void)beginWithDownloadFetcher:(GTMHTTPFetcher *)argFetcher
                  previousLength:(NSUInteger)argLength
                           owner:(id)argOwner
          receiveDataLengthBlock:(void (^)(NSUInteger currentLength, NSUInteger totalLength))argReceiveBlock
          completeDownloadHandle:(SEL)argHandle
           completeDownloadBlock:(void (^)(NSError *error))argBlock {
    GTMHTTPFetcher __weak *fet = argFetcher;
    if (self.hostDictionary != nil) {
        fet.mutableRequest = [self addHostToRequest:fet.mutableRequest];
    }
    [argFetcher setReceivedDataBlock:^(NSData *data) {
        if (argReceiveBlock != nil) {
            NSDictionary *dict = fet.responseHeaders;
            NSUInteger tLength = (NSUInteger)[dict[@"Content-Length"] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                argReceiveBlock((NSUInteger)fet.downloadedLength + argLength,tLength + argLength);
            });
        }
    }];
    
    [argFetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        dispatch_queue_t myDispatchQueue = dispatch_get_main_queue();
        dispatch_async(myDispatchQueue, ^{
            if (argBlock) {
                argBlock(error);
            }
            if (argOwner && argHandle) {
                //由于performSelector方法有可能出现内存泄露，所以使用下列语句替换
                IMP imp = [argOwner methodForSelector:argHandle];
                void (*func)(id, SEL , NSError *) = (void *)imp;
                func(argOwner, argHandle, error);
            }
        });
    }];
}

- (void)beginWithUploadFetcher:(GTMHTTPFetcher *)argFetcher
                         owner:(id)argOwner
           sendDataLengthBlock:(void (^)(NSUInteger currentLength, NSUInteger totalLength))argSendBlock
        completeUploadHandle:(SEL)argHandle
         completeUploadBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock {
    GTMHTTPFetcher __weak *fet = argFetcher;
    if (self.hostDictionary != nil) {
        fet.mutableRequest = [self addHostToRequest:fet.mutableRequest];
    }
    [argFetcher setSentDataBlock:^(NSInteger bytesSent, NSInteger totalBytesSent, NSInteger bytesExpectedToSend) {
        if (argSendBlock != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                argSendBlock(totalBytesSent,bytesExpectedToSend);
            });
        }
    }];
    
    [argFetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        TMOHTTPResult *result = [TMOHTTPResult createHTTPResultWithRequest:fet.mutableRequest WithResponse:fet.response WithData:data];
        dispatch_queue_t myDispatchQueue = dispatch_get_main_queue();
        dispatch_async(myDispatchQueue, ^{
            if (argBlock) {
                argBlock(result, error);
            }
            if (argOwner && argHandle) {
                //由于performSelector方法有可能出现内存泄露，所以使用下列语句替换
                IMP imp = [argOwner methodForSelector:argHandle];
                void (*func)(id, SEL , TMOHTTPResult *, NSError *) = (void *)imp;
                func(argOwner, argHandle, result, error);
            }
        });
    }];
}

#pragma mark Reachability

- (void)reachabilityChanged:(NSNotification *)notification {
    if (![_fetcherReachability isReachable]) {
        self.reachabilityStatus = TMOReachabilityStatusNoNetWork;
        _isNetWorkOK = NO;
    } else {
        _isNetWorkOK = YES;
    }
    if ([_fetcherReachability isReachableViaWiFi]) {
        self.reachabilityStatus = TMOReachabilityStatusWiFi;
    }
    if ([_fetcherReachability isReachableViaWWAN]) {
        self.reachabilityStatus = TMOReachabilityStatusWWAN;
    }
    TMOReachabilityStatus status = _reachabilityStatus;
    if (self.reachabilityStatusBlock) {
        self.reachabilityStatusBlock(status);
    }
}

- (void)setReachabilityStatusChangeBlock:(void (^)(TMOReachabilityStatus))block {
    self.reachabilityStatusBlock = block;
}

- (void)networkStatus:(void (^)(TMOReachabilityStatus))argCallback {
    double delayInSeconds = 0.001;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (argCallback != nil) {
            argCallback(self.reachabilityStatus);
        }
    });
}

#pragma mark -
#pragma mark - 与Http服务相关的支持方法

- (long long)cacheSize {
    return self.cacheDatabase.currentSize;
}

- (void)cleanAllCache {
    [TMOKVDB closeAndReleaseSpace:kTMONetworkCacheDatabaseKey];
}

- (void)cleanExpiredCache {
    [self.cacheDatabase removeGarbage];
}

@end
