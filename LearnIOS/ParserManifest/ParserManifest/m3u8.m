//
//  m3u8.m
//  ParserManifest
//
//  Created by Lee Li on 2020/4/20.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "m3u8.h"
#import "parser.h"


#define M3U8_TAG_FILE_START                 @"#EXTM3U"
#define M3U8_TAG_FILE_END                   @"#EXT-X-ENDLIST\n"
#define M3U8_TAG_ITEM                       @"#EXTINF:"
#define M3U8_TAG_TARGET_DURATION            @"#EXT-X-TARGETDURATION:"
#define M3U8_TAG_VERSION                    @"#EXT-X-VERSION:"
#define M3U8_TAG_SEQUENCE                   @"#EXT-X-MEDIA-SEQUENCE:"
#define M3U8_TAG_PLAYLIST_TYPE              @"#EXT-X-PLAYLIST-TYPE:"
#define M3U8_TAG_ITEM_DURATION              @"#EXTINF:"
#define M3U8_TAG_BYTERANGE                  @"#EXT-X-BYTERANGE:"
#define M3U8_TAG_KEY                        @"#EXT-X-KEY:"

#define M3U8_FORMAT_TARGET_DURATION      @"#EXT-X-TARGETDURATION:%ld\n"
#define M3U8_FORMAT_VERSION              @"#EXT-X-VERSION:%d\n"
#define M3U8_FORMAT_SEQUENCE             @"#EXT-X-MEDIA-SEQUENCE:%d\n"
#define M3U8_FORMAT_PLAYLIST_TYPE        @"#EXT-X-PLAYLIST-TYPE:%@\n"
#define M3U8_FORMAT_ITEM_DURATION        @"#EXTINF:%d,\n"
#define M3U8_FORMAT_BYTERANGE            @"#EXT-X-BYTERANGE:%@\n"
#define M3U8_FORMAT_KEY                  @"#EXT-X-KEY:%@\n"
#define M3U8_FORMAT_NEW_LINE             @"%@\n\r"
@interface VOAVM3u8Master()
{
    NSInteger _duration;
}

@end
const int VALUE_UNKNOW = -1;

@implementation VOAVM3u8Master

-(void) test
{
    printf("lee test");
    
    NSString * url = @"http://stream1.visualon.com:8082/hls/v10/gear/bipbop_16x9_variant_v10_2.m3u8";
    
    [self initWithURL:url];
    
    NSString *rootPath = [url urlStringByDeletingLastComponent];
    [self addRelativePath:rootPath];
    
}
- (instancetype)initWithURL:(NSString *)URLString
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:trim(URLString)]];
    
    if (data == nil) {
        return nil;
    }
    
    return [self initWithData:data];
}

- (instancetype)initWithData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return [self initWithString:string];
}

- (instancetype)initWithString:(NSString *)string
{
    if (self = [super init]) {
        _version = VALUE_UNKNOW;
        _duration = VALUE_UNKNOW;
        BOOL result = [self parsue:string];
        if (result == NO) {
            return nil;
        }
    }
    
    return self;
}

- (BOOL)parsue:(NSString *)string
{
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    if (lines == nil || lines.count == 0) {
        return NO;
    }
    
    for (int i = 0; i < lines.count; ++i) {
        NSString *line = lines[i];
        if (i == 0 && ![line containsString:M3U8_TAG_FILE_START]) {
            return NO;
        }
        
        if ([line hasPrefix:M3U8_TAG_VERSION]) {
            self.version = [[line stringByDeletingPrefix:M3U8_TAG_VERSION] intValue];
        }
        
        if ([line hasPrefix:M3U8_TAG_MASTER_MEDIA] ||
            [line hasPrefix:M3U8_TAG_MASTER_STREAM_IFRAME] ||
            [line hasPrefix:M3U8_TAG_MASTER_STREAM]) {
            VOAVTrackInfo *trackInfo = [VOAVTrackInfo trackInfoWithString:line];
            
            if ([line hasPrefix:M3U8_TAG_MASTER_STREAM]) {
                do {
                    if (++i >= lines.count) return NO;
                    line = trim(lines[i]);
                } while ([line isSpaceLine]);
                
                [((VOAVTrackInfoStream *)trackInfo) setURI:line];
            }
            
            //re
            
            if ([trackInfo.type isEqualToString: VOAVTrackTypeSubtitle] || [trackInfo.type isEqualToString: VOAVTrackTypeAudio])
            {
                int a = 0;
                bool flag = true;
                while (flag)
                {
                    NSArray<VOAVTrackInfo *> *subtitleList = [self getTrackGroup:trackInfo.type];
                    if (subtitleList.count == 0) {
                        flag = false;
                    }
                    for (VOAVTrackInfo *info in subtitleList)
                    {
                        if ([trackInfo.language isEqualToString: info.language])
                        {
                            a++;
                            NSMutableString* language1 = [[NSMutableString alloc]initWithString:info.language];
                            NSString *language2 = [NSString stringWithFormat:@"%d",a];
                            [language1 insertString:language2 atIndex:info.language.length-1];

                            printf("lee language redefined,:%s,language:%s\n",[info.language UTF8String],[language1 UTF8String]);
                            
                            [trackInfo setLanguage:language1];
                        }
                        else
                            flag = false;
                    }
                }
            }
            
            [self.trackInfoList addObject:trackInfo];
        }
    }
    
    return YES;
}
#pragma mark getter method
- (NSMutableArray<VOAVTrackInfo *> *)trackInfoList
{
    if (_trackInfoList == nil) {
        _trackInfoList = [NSMutableArray array];
    }

    return _trackInfoList;
}

- (NSArray<VOAVTrackInfo *> *)getTrackGroup:(VOAVTrackType)type
{
    NSMutableArray *trackList = [NSMutableArray array];
    for (VOAVTrackInfo *track in _trackInfoList) {
        if ([track.type isEqualToString:type]) {
            [trackList addObject:track];
        }
    }
    
    return trackList;
}

- (void)addRelativePath:(NSString *)relativePath
{
    if (relativePath == nil) {
        return;
    }
    
    for (VOAVTrackInfo *trackInfo in self.trackInfoList) {
        if (trackInfo.type == VOAVTrackTypeAudio) {
            continue;
        }
        [trackInfo addRelativePath:relativePath];
    }
}

- (NSString *)makeString
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@\n",M3U8_TAG_FILE_START];
    if (self.version != VALUE_UNKNOW) {
        [string appendFormat:M3U8_FORMAT_VERSION, self.version];
    }
    [string appendString:@"\r"];
    
    for (VOAVTrackInfo *track in self.trackInfoList )
    {
        if ([track.type isEqualToString: VOAVTrackTypeSubtitle] || [track.type isEqualToString: VOAVTrackTypeAudio])
        {
            [string appendFormat:M3U8_FORMAT_NEW_LINE,[track makeString]];
        }
        
    }
    
    return string;
}
@end


