//
//  UIImageView+TMOImageView.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-8.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "UIImageView+TMOImageView.h"
#import "TMOHTTPManager.h"
#import "UIView+TMOView.h"

@implementation UIImageView (TMOImageView)

- (void)setPlaceHolderImage:(UIImage *)placeHolderImage {
    [self setAdditionValue:placeHolderImage forKey:@"placeHolderImage"];
}

- (UIImage *)placeHolderImage {
    return [self valueForAdditionKey:@"placeHolderImage"];
}

- (void)setErrorImage:(UIImage *)errorImage {
    [self setAdditionValue:errorImage forKey:@"errorImage"];
}

- (UIImage *)errorImage {
    return [self valueForAdditionKey:@"errorImage"];
}

- (void)setCacheTime:(NSTimeInterval)argCacheTime {
    [self setAdditionValue:[NSNumber numberWithInteger:argCacheTime] forKey:@"imageViewCacheTime"];
}

- (NSTimeInterval)cacheTime {
    if ([self valueForAdditionKey:@"imageViewCacheTime"] == nil) {
        return 86400;
    }
    return [[self valueForAdditionKey:@"imageViewCacheTime"] integerValue];
}

- (void)loadImageWithURLString:(NSString *)urlString {
    if ([[[NSURL URLWithString:urlString] host] length] == 0) {
        return;
    }
    if (self.placeHolderImage != nil) {
        self.image = self.placeHolderImage;
    }
    NSTimeInterval cacheTime = [self cacheTime];
    [self setAdditionValue:urlString forKey:@"imageViewURLString"];
    [[TMOHTTPManager shareInstance] fetchWithURL:urlString
                                        postData:nil
                                 timeoutInterval:60
                                         headers:nil
                                           owner:self
                                       cacheTime:cacheTime
                                 fetcherPriority:TMOFetcherPriorityLow
                                 comletionHandle:nil
                                 completionBlock:^(TMOHTTPResult *result, NSError *error) {
                                     if (error || ![result.request.URL.absoluteString isEqualToString:[self valueForAdditionKey:@"imageViewURLString"]]) {
                                         //加载失败
                                         if (self.errorImage != nil) {
                                             self.image = self.errorImage;
                                         }
                                     }
                                     else {
                                         //加载完成
                                         self.image = [UIImage imageWithData:result.data];
                                     }
                                 }];
}

- (void)loadImageWithURLString:(NSString *)urlString
                    callBefore:(void(^)(UIImageView *imageView))argCallBefore
                     callAfter:(void(^)(UIImageView *imageView, UIImage *image))argCallAfter {
    if ([[[NSURL URLWithString:urlString] host] length] == 0) {
        return;
    }
    if (self.placeHolderImage != nil) {
        self.image = self.placeHolderImage;
    }
    if (argCallBefore != nil) {
        argCallBefore(self);
    }
    NSTimeInterval cacheTime = [self cacheTime];
    [self setAdditionValue:urlString forKey:@"imageViewURLString"];
    [[TMOHTTPManager shareInstance] fetchWithURL:urlString
                                        postData:nil
                                 timeoutInterval:60
                                         headers:nil
                                           owner:self
                                       cacheTime:cacheTime
                                 fetcherPriority:TMOFetcherPriorityLow
                                 comletionHandle:nil
                                 completionBlock:^(TMOHTTPResult *result, NSError *error) {
                                     if (error || ![result.request.URL.absoluteString isEqualToString:[self valueForAdditionKey:@"imageViewURLString"]]) {
                                         //加载失败
                                         if (self.errorImage != nil) {
                                             self.image = self.errorImage;
                                         }
                                         if (argCallAfter != nil) {
                                             argCallAfter(self, nil);
                                         }
                                     }
                                     else {
                                         //加载完成
                                         if (argCallAfter != nil) {
                                             argCallAfter(self, [UIImage imageWithData:result.data]);
                                         }
                                     }
                                 }];
}

@end
