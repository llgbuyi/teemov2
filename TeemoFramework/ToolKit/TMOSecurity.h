//
//  TMOSecurity.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-11.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#define kTMOSecurityAreaKeychain @"kTMOSecurityAreaKeychain"
#define kTMOSecurityAreaCache @"kTMOSecurityAreaCache"
#define kTMOSecurityAreaDocument @"kTMOSecurityAreaDocument"

#import <Foundation/Foundation.h>

@interface TMOSecurity : NSObject

+ (id)objectFromSecurityArea:(NSString *)argSecurityArea withIdetifier:(NSString *)argIdentifier;

@end

@interface NSObject (TMOSecurity)

- (void)saveToSecurityKeychainWithIdentifier:(NSString *)argIdentifier;

- (void)saveToSecurityCacheWithIdentifier:(NSString *)argIdentifier;

- (void)saveToSecurityDocumentWithIdentifier:(NSString *)argIdentifier;

@end

@interface NSData (TMOSecurity)

- (NSData *)dataByAESEncode;

- (NSData *)dataByAESEncodeWithService:(NSString *)argService;

- (NSData *)dataByAESEncodeWithKey:(NSString *)argKey;

- (NSData *)dataByAESDecode;

- (NSData *)dataByAESDecodeWithService:(NSString *)argService;

- (NSData *)dataByAESDecodeWithKey:(NSString *)argKey;

@end