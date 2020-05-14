//
//  m3u8.h
//  ParserManifest
//
//  Created by Lee Li on 2020/4/20.
//  Copyright © 2020 Lee Li. All rights reserved.
//

//#ifndef m3u8_h
//#define m3u8_h
//
//
//#endif /* m3u8_h */
#import "m3u8.h"
#import "parser.h"
#import "track.h"
@interface VOAVM3u8Master : NSObject
@property (nonatomic, strong)NSMutableArray<VOAVTrackInfo *> *trackInfoList;
-(void) test;

@property(nonatomic, assign)int version;

- (instancetype)initWithData:(NSData *)data;

- (instancetype)initWithString:(NSString *)string;

- (instancetype)initWithURL:(NSString *)URLString;

- (void)addRelativePath:(NSString *)relativePath;

- (NSArray<VOAVTrackInfo *> *)getTrackGroup:(VOAVTrackType)type;

- (NSString *)makeString;
@end

