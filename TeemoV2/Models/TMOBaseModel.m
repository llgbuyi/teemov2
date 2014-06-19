//
//  TMOBaseModel.m
//  TeemoV2
//
//  Created by 曾 宪华 on 14-6-13.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOBaseModel.h"

@implementation TMOBaseModel

- (NSString *)description {
    return [NSString stringWithFormat:@"content : %@  index : %d", self.content, self.index];
}

- (BOOL)isEqual:(TMOBaseModel *)object {
    return [self.content isEqualToString:object.content];
}

- (NSUInteger)hash {
    return [self.content hash];
}

@end
