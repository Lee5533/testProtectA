//
//  track.h
//  ParserManifest
//
//  Created by Lee Li on 2020/4/21.
//  Copyright © 2020 Lee Li. All rights reserved.
//

//#ifndef track_h
//#define track_h
//
//
//#endif /* track_h */


#import <Foundation/Foundation.h>

#define M3U8_TAG_MASTER_MEDIA           @"#EXT-X-MEDIA:"
#define M3U8_TAG_MASTER_STREAM          @"#EXT-X-STREAM-INF:"
#define M3U8_TAG_MASTER_STREAM_IFRAME   @"#EXT-X-I-FRAME-STREAM-INF:"

typedef NSString *const VOAVTrackType;
typedef NSString *const VOAVMetaDataKey;

extern VOAVTrackType VOAVTrackTypeAudio;
extern VOAVTrackType VOAVTrackTypeSubtitle;
extern VOAVTrackType VOAVTrackTypeVideo;
extern VOAVTrackType VOAVTrackTypeIFrame;

extern VOAVMetaDataKey VOAVMetaDataKeyURI;         // EXT-X-MEDIA:URI
extern VOAVMetaDataKey VOAVMetaDataKeyType;        // EXT-X-MEDIA:TYPE
extern VOAVMetaDataKey VOAVMetaDataKeyGroupID;     // EXT-X-MEDIA:GROUP-ID
extern VOAVMetaDataKey VOAVMetaDataKeyLanguage;    // EXT-X-MEDIA:LANGUAGE
extern VOAVMetaDataKey VOAVMetaDataKeyName;        // EXT-X-MEDIA:NAME
extern VOAVMetaDataKey VOAVMetaDataKeyAutoSelect;  // EXT-X-MEDIA:AUTOSELECT
extern VOAVMetaDataKey VOAVMetaDataKeyDefault;     // EXT-X-MEDIA:DEFAULT
extern VOAVMetaDataKey VOAVMetaDataKeyForced;      // EXT-X-MEDIA:FORCED
extern VOAVMetaDataKey VOAVMetaDataKeyVideoRange;  // EXT-X-MEDIA:VIDEO-RANGE



@interface VOAVTrackInfo : NSObject

@property (nonatomic, readonly)VOAVTrackType type;
@property (nonatomic, readonly)VOAVMetaDataKey language;
//@property (nonatomic, strong)NSMutableDictionary *propertyDict;
- (instancetype)initWithKeyValueString:(NSString *)string;
- (NSString *)getTrackTag;
+ (VOAVTrackInfo *)trackInfoWithString:(NSString *)string;
- (NSString *)getPropertyValue:(VOAVMetaDataKey)key;
- (NSString *)makeString;
- (void)addRelativePath:(NSString *)relativePath;
- (void)setLanguage:(NSString *)language;

@end


/*******************************************************
 *
 VOAVTrackInfoMedia
 *
 *******************************************************/

@interface VOAVTrackInfoMedia : VOAVTrackInfo

@end

/*******************************************************
 *
 VOAVTrackInfoIframe
 *
 *******************************************************/

extern VOAVMetaDataKey VOAVMetaDataKeyProgramID;   // #EXT-X-STREAM-INF:PROGRAM-ID
extern VOAVMetaDataKey VOAVMetaDataKeyBandwidth;   // #EXT-X-STREAM-INF:BANDWIDTH-ID
extern VOAVMetaDataKey VOAVMetaDataKeyCodecs;      // #EXT-X-STREAM-INF:CODECS

@interface VOAVTrackInfoIframe : VOAVTrackInfo

@end

/*******************************************************
 *
     VOAVTrackInfoStream
 *
 *******************************************************/

extern VOAVMetaDataKey VOAVMetaDataKeyResolution;   // #EXT-X-STREAM-INF:RESOLUTION
extern VOAVMetaDataKey VOAVMetaDataKeyAudio;        // #EXT-X-STREAM-INF:AUDIO
extern VOAVMetaDataKey VOAVMetaDataKeySubtitles;    // #EXT-X-STREAM-INF:SUBTITLES
extern VOAVMetaDataKey VOAVMetaDataKeyFrameRate;    //#EXT-X-STREAM-INF:FRAME-RATE

@interface VOAVTrackInfoStream : VOAVTrackInfo

@property (nonatomic, strong)NSString *URI;


@end
