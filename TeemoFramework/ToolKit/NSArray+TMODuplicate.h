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
 *  去重的算法
 *
 *  @param currentArray 需要添加的目标数组
 *
 *  @return 返回目标数组合并到本身后，再去重的数组
 */
- (NSArray *)unionWithoutDuplicatesWithArray:(NSArray *)currentArray;

@end
