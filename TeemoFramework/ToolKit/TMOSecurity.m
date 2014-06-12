//
//  TMOSecurity.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-6-11.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOSecurity.h"
#import "NSString+TMOString.h"
#import <SSKeychain.h>
#import <RNEncryptor.h>
#import <RNDecryptor.h>
#import "TMOKVDB.h"

@interface TMOSecurity ()

+ (NSString *)secretKeyForService:(NSString *)argService;

@end

static NSString *documentPath () {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/com.duowan.security/"];
}

static NSString *cachePath () {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/com.duowan.security/"];
}

@implementation TMOSecurity

+ (NSString *)secretKeyForService:(NSString *)argService {
    NSString *keychainSecretKey;
    if ((keychainSecretKey = [SSKeychain passwordForService:argService account:@"$default"]) != nil) {
        return keychainSecretKey;
    }
    else {
        return [self generateKeyForService:argService];
    }
}

+ (NSString *)generateKeyForService:(NSString *)argService {
    NSString *finalKey = @"";
    for (NSUInteger j=0; j<8; j++) {
        NSString *randomString = [NSString stringWithFormat:@"%@.%d.%d.%d.%@", argService, arc4random(), arc4random(), arc4random(), argService];
        NSInteger randomHashTime = arc4random() % 100;
        NSString *key = randomString;
        for (NSUInteger i = 0; i < randomHashTime; i++) {
            key = [key stringByMD5Hash];
        }
        finalKey = [finalKey stringByAppendingString:key];
    }
    [SSKeychain setPassword:finalKey forService:argService account:@"$default"];
    return finalKey;
}



+ (id)objectFromSecurityArea:(NSString *)argSecurityArea withIdetifier:(NSString *)argIdentifier {
    if ([argSecurityArea isEqualToString:kTMOSecurityAreaKeychain]) {
        return [SSKeychain passwordForService:@"TMOSecurityArea" account:argIdentifier];
    }
    else {
        NSData *storageData = [self dataFromSecurityArea:argSecurityArea withIdetifier:argIdentifier];
        if (storageData == nil) {
            return nil;
        }
        else {
            return [NSKeyedUnarchiver unarchiveObjectWithData:storageData];
        }
    }
}

+ (NSData *)dataFromSecurityArea:(NSString *)argSecurityArea withIdetifier:(NSString *)argIdentifier {
    NSData *encodedData;
    NSString *cacheKey = [NSString stringWithFormat:@"com.duowan.security.%@", argIdentifier];
    if ([argSecurityArea isEqualToString:kTMOSecurityAreaDocument]) {
        encodedData = [[TMOKVDB customDatabase:documentPath()] valueForKey:cacheKey];
    }
    else if ([argSecurityArea isEqualToString:kTMOSecurityAreaCache]) {
        encodedData = [[TMOKVDB customDatabase:cachePath()] valueForKey:cacheKey];
    }
    NSData *decodedData = [encodedData dataByAESDecode];
    return decodedData;
}

@end

@implementation NSObject (TMOSecurity)

- (void)saveToSecurityKeychainWithIdentifier:(NSString *)argIdentifier {
    if ([self isKindOfClass:[NSString class]]) {
        [SSKeychain setPassword:(NSString *)self forService:@"TMOSecurityArea" account:argIdentifier];
    }
    else {
        NSAssert(false, @"只支持NSString保存到KeyChain");
    }
}

- (void)saveToSecurityDocumentWithIdentifier:(NSString *)argIdentifier {
    NSString *cacheKey = [NSString stringWithFormat:@"com.duowan.security.%@", argIdentifier];
    NSData *encodedData = [self saveToSecurityData];
    [[TMOKVDB customDatabase:documentPath()] setObject:encodedData forKey:cacheKey];
}

- (void)saveToSecurityCacheWithIdentifier:(NSString *)argIdentifier {
    NSString *cacheKey = [NSString stringWithFormat:@"com.duowan.security.%@", argIdentifier];
    NSData *encodedData = [self saveToSecurityData];
    [[TMOKVDB customDatabase:cachePath()] setObject:encodedData forKey:cacheKey];
}

- (NSData *)saveToSecurityData {
    NSData *theData;
    if ([self isKindOfClass:[NSString class]] ||
        [self isKindOfClass:[UIImage class]] ||
        [self isKindOfClass:[NSDictionary class]] ||
        [self isKindOfClass:[NSArray class]] ||
        [self isKindOfClass:[NSNumber class]]) {
        NSData *preData = [NSKeyedArchiver archivedDataWithRootObject:self];
        theData = [preData dataByAESEncode];
        return theData;
    }
    else if ([self isKindOfClass:[NSData class]]) {
        theData = [(NSData *)self dataByAESEncode];
        return theData;
    }
    else {
        NSAssert(false, @"传入了不受支持的加密数据类型");
        return nil;
    }
}

@end


@implementation NSData (TMOSecurity)

- (NSData *)dataByAESEncode {
    return [self dataByAESEncodeWithService:@"defaultService"];
}

- (NSData *)dataByAESEncodeWithService:(NSString *)argService {
    return [self dataByAESEncodeWithKey:[TMOSecurity secretKeyForService:argService]];
}

- (NSData *)dataByAESEncodeWithKey:(NSString *)argKey {
    return [RNEncryptor encryptData:self withSettings:kRNCryptorAES256Settings password:argKey error:nil];
}

- (NSData *)dataByAESDecode {
    return [self dataByAESDecodeWithService:@"defaultService"];
}

- (NSData *)dataByAESDecodeWithService:(NSString *)argService {
    return [self dataByAESDecodeWithKey:[TMOSecurity secretKeyForService:argService]];
}

- (NSData *)dataByAESDecodeWithKey:(NSString *)argKey {
    return [RNDecryptor decryptData:self withPassword:argKey error:nil];
}

@end
