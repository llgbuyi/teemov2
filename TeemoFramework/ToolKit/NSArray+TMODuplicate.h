//
//  NSArray+TMODuplicate.h
//  TeemoV2
//
//  Created by 曾 宪华 on 14-6-13.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TMODuplicate)

/**
 *  合并两个数组，并且去重
 *
 *  @param currentArray 需要添加的目标数组
 *
 *  @return 返回去重的数组
 */
- (NSArray *)unionWithoutDuplicatesWithArray:(NSArray *)currentArray;

/**
 *  根据某个key合并两个数组，并且根据该key进行去重
 *
 *  @param currentArray 需要添加的目标数组
 *
 *  @return 返回去重的数组
 */
- (NSArray *)unionWithoutDuplicatesWithArray:(NSArray *)currentArray forKey:(NSString *)currentKey;

@end
