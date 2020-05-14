//
//  parser.m
//  ParserManifest
//
//  Created by Lee Li on 2020/4/21.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "parser.h"

@implementation NSString (VOParser1)

- (instancetype)stringByDeletingPrefix:(NSString *)prefix
{
    if (prefix.length >= self.length) {
        return self;
    }
    
    NSRange range = [self rangeOfString:prefix];
    NSString *subString = self;
    if (range.location == 0) {
        subString = [subString substringFromIndex:endPosition(range)];
    }
    
    return subString;
}
- (void)test2
{
//    printf("lee test2");
}
- (BOOL)isSpaceLine
{
    if (self.length == 0) {
        return YES;
    }
    
    if ([self hasPrefix:@"\r"]) {
        return YES;
    }
    
    return NO;
}

- (NSMutableDictionary *)parserToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *keyValuesString = trim(self);
    
    NSRange range = NSMakeRange(0, 0);
    NSString *key;
    NSString *value;
    BOOL inQuotation = NO;
    for (int i = 0; i < keyValuesString.length; i++) {
        char cur = [keyValuesString characterAtIndex:i];
        if (cur == '"') {
            inQuotation = !inQuotation;
        }
        
        if (inQuotation) {
            continue;
        }
        
        if (cur == '=') {
            range.length = i - range.location;
            key = trim([keyValuesString substringWithRange:range]);
            range.location = i + 1;
        } else if (cur == ',') {
            range.length = i - range.location;
            value = trim([keyValuesString substringWithRange:range]);
            [dict setObject:value forKey:key];
            range.location = i + 1;
        }
    }
    
    value = [keyValuesString substringFromIndex:range.location];
    [dict setObject:value forKey:key];
    
    return dict;
}

+ (instancetype)absoluteURLPath:(NSString *)rootPath pathComponent:(NSString *)pathComponent
{
    NSString *absoluteURLPath = nil;
    if (pathComponent == nil) {
        return nil;
    }
    
    if ([pathComponent containsString:@"://"]) {
        absoluteURLPath = [NSString stringWithString:pathComponent];
        return absoluteURLPath;
    }
    
    if (![rootPath hasSuffix:@"/"]) {
        rootPath = [rootPath stringByAppendingString:@"/"];
    }
    
    absoluteURLPath = [rootPath stringByAppendingString:pathComponent];
    
    return absoluteURLPath;
}

- (instancetype)stringByTrimDoubleQuotationMarks
{
    if (![self hasDoubleQuotationMarks]) {
        return self;
    }
    
    NSRange range = NSMakeRange(1, self.length - 2);
    
    return [self substringWithRange:range];
}

- (instancetype)stringByAddingDoubleQuotationMarks
{
    return [NSString stringWithFormat:@"\"%@\"",self];
}
- (BOOL)hasDoubleQuotationMarks
{
    if (self.length <= 1) {
        return NO;
    }
    
    return [self hasPrefix:@"\""] && [self hasSuffix:@"\""];
}
- (instancetype)urlStringByDeletingLastComponent
{
    NSString *lastComponent = [@"/" stringByAppendingString:self.lastPathComponent];
    NSRange rane = [self rangeOfString:lastComponent];
    
    if (rane.location == NSNotFound) {
        return self;
    }
    
    return [self substringToIndex:rane.location];
}

@end
