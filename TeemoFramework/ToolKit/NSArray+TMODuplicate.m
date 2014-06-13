//
//  NSArray+TMODuplicate.m
//  TeemoV2
//
//  Created by 曾 宪华 on 14-6-13.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "NSArray+TMODuplicate.h"

@implementation NSArray (TMODuplicate)

- (NSArray *)unionWithoutDuplicatesWithArray:(NSArray *)currentArray {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:self];
    
    [mutableArray addObjectsFromArray:[[NSSet setWithArray:currentArray] allObjects]];
    [mutableArray setArray:[[NSSet setWithArray:mutableArray] allObjects]];
    
    return mutableArray;
}

@end
