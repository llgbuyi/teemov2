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

- (NSArray *)unionWithoutDuplicatesWithArray:(NSArray *)currentArray forKey:(NSString *)currentKey {
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self];
    [mutableArray addObjectsFromArray:currentArray];
    
    NSArray *copy = [mutableArray copy];
    NSInteger index = [copy count] - 1;
    for (id object in [copy reverseObjectEnumerator]) {
        
        for (NSUInteger i = 0; i < index; i++) {
            if ([[mutableArray[i] valueForKey:currentKey] isEqualToString:[object valueForKey:currentKey]]){
                [mutableArray removeObjectAtIndex:index];
                break;
            }
        }
        index --;
    }
    
    return mutableArray;
}

@end
