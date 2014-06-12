//
//  TMOHTTPResult.h
//  TeemoV2
//
//  Created by 张培创 on 14-4-1.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMOHTTPResult : NSObject

/**
 *  请求的Request，你可以在这里获取本次Request有关的信息
 */
@property (nonatomic, strong, readonly) NSURLRequest *request;

/**
 *  返回response
 */
@property (nonatomic, strong, readonly) NSURLResponse *response;

/**
 *  返回数据Data
 */
@property (nonatomic, strong, readonly) NSData *data;

/**
 *  获取抓取得到的文本（UTF-8编码）
 */
@property (nonatomic, strong, readonly) NSString *text;

/**
 *  将获取得到的JSON文本，转换为对象
 */
@property (nonatomic, strong, readonly) id JSONObj;

/**
 *  获取一个结果对象，只能通过本方法获取实例对象
 *
 *  @param request  request
 *  @param response response
 *  @param data     data
 *
 *  @return TMOHTTPResult
 */
+ (TMOHTTPResult *)createHTTPResultWithRequest:(NSURLRequest *)request
                                  WithResponse:(NSURLResponse *)response
                                      WithData:(NSData *)data;

/**
 *  当获取的文本编码不是UTF-8时，使用此方法获取你想要的文本
 *
 *  @param encoding 文本编码
 *
 *  @return NSString
 */
- (NSString *)textUsingStringEncoding:(NSStringEncoding)encoding;

@end
