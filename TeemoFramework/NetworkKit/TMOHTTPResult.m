//
//  TMOHTTPResult.m
//  TeemoV2
//
//  Created by 张培创 on 14-4-1.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOHTTPResult.h"
#import "JSONKit.h"

@interface TMOHTTPResult ()

@property (nonatomic, strong, readwrite) NSURLRequest *request;
@property (nonatomic, strong, readwrite) NSURLResponse *response;
@property (nonatomic, strong, readwrite) NSData *data;

@end

@implementation TMOHTTPResult

+ (TMOHTTPResult *)createHTTPResultWithRequest:(NSURLRequest *)request
                                  WithResponse:(NSURLResponse *)response
                                      WithData:(NSData *)data {
    TMOHTTPResult *result = [[TMOHTTPResult alloc] init];
    result.request = request;
    result.response = response;
    result.data = data;
    return result;
}

- (NSString *)text {
    return [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
}

- (NSString *)textUsingStringEncoding:(NSStringEncoding)encoding {
    return [[NSString alloc] initWithData:_data encoding:encoding];
}

- (id)JSONObj {
    return [_data objectFromJSONData];
}

@end
