//
//  parser.h
//  ParserManifest
//
//  Created by Lee Li on 2020/4/21.
//  Copyright © 2020 Lee Li. All rights reserved.
//

//#ifndef parser_h
//#define parser_h
//
//
//#endif /* parser_h */
#define trim(str)   [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
#define endPosition(range) (range.location + range.length)
#define deleteLastChar(mStr)  [mStr deleteCharactersInRange:NSMakeRange(mStr.length - 1, 1)]

@interface NSString (VOParser1)
- (instancetype)stringByDeletingPrefix:(NSString *)prefix;
- (BOOL)isSpaceLine;
- (NSMutableDictionary *)parserToDictionary;
- (void)test2;
+ (instancetype)absoluteURLPath:(NSString *)rootPath pathComponent:(NSString *)pathComponent;
- (instancetype)stringByTrimDoubleQuotationMarks;

- (instancetype)stringByAddingDoubleQuotationMarks;
- (BOOL)hasDoubleQuotationMarks;
- (instancetype)urlStringByDeletingLastComponent;
@end
