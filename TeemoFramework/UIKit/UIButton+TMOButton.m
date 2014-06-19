//
//  UIButton+TMOButton.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-10.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#define kTMOButtonCustomImageViewTag -10000
#import "UIButton+TMOButton.h"
#import "TMOHTTPManager.h"

@implementation UIButton (TMOButton)

- (void)setCustomImageView:(void (^)(UIImageView *))argCallback {
    UIImageView *imageView;
    if ([self viewWithTag:kTMOButtonCustomImageViewTag] != nil &&
        [[self viewWithTag:kTMOButtonCustomImageViewTag] isKindOfClass:[UIImageView class]]) {
        imageView = (UIImageView *)[self viewWithTag:kTMOButtonCustomImageViewTag];
    }
    else {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.tag = kTMOButtonCustomImageViewTag;
        [self addSubview:imageView];
    }
    if (argCallback != nil) {
        argCallback(imageView);
    }
}

- (void)setCustomImageForState:(UIControlState)argControlState
                 withURLString:(NSString *)argURLString
          withPlaceHolderImage:(UIImage *)argPlaceHolderImage {
    [self setCustomImageForState:argControlState
                   withURLString:argURLString
            withPlaceHolderImage:argPlaceHolderImage
                   withCacheTime:86400];
}

- (void)setCustomImageForState:(UIControlState)argControlState
                 withURLString:(NSString *)argURLString
          withPlaceHolderImage:(UIImage *)argPlaceHolderImage
                 withCacheTime:(NSTimeInterval)argCacheTime {
    if (argPlaceHolderImage != nil) {
        [self setImage:argPlaceHolderImage forState:argControlState];
    }
    [[TMOHTTPManager shareInstance] fetchWithURL:argURLString
                                        postData:nil
                                 timeoutInterval:60
                                         headers:nil
                                           owner:nil
                                       cacheTime:argCacheTime
                                 fetcherPriority:TMOFetcherPriorityNormal
                                 comletionHandle:nil
                                 completionBlock:^(TMOHTTPResult *result, NSError *error) {
        if (error == nil) {
            UIImage *image = [UIImage imageWithData:result.data];
            if (image != nil) {
                [self setImage:image forState:argControlState];
            }
        }
    }];
}

@end
