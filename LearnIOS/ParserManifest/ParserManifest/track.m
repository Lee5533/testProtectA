//
//  track.m
//  ParserManifest
//
//  Created by Lee Li on 2020/4/21.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "track.h"
#import "parser.h"


#define updateProperty(key,value)     [propertyDict setValue:value forKey:key]

#define M3U8_KEY_VALUE_FORMAT           @"%@=%@,"

VOAVTrackType VOAVTrackTypeAudio        = @"AUDIO";;
VOAVTrackType VOAVTrackTypeSubtitle     = @"SUBTITLES";
VOAVTrackType VOAVTrackTypeVideo        = @"VIDEO";
VOAVTrackType VOAVTrackTypeIFrame       = @"IFRAME";

VOAVMetaDataKey VOAVMetaDataKeyURI          = @"URI";
VOAVMetaDataKey VOAVMetaDataKeyType         = @"TYPE";
VOAVMetaDataKey VOAVMetaDataKeyGroupID      = @"GROUP-ID";
VOAVMetaDataKey VOAVMetaDataKeyLanguage     = @"LANGUAGE";
VOAVMetaDataKey VOAVMetaDataKeyName         = @"NAME";
VOAVMetaDataKey VOAVMetaDataKeyAutoSelect   = @"AUTOSELECT";
VOAVMetaDataKey VOAVMetaDataKeyDefault      = @"DEFAULT";
VOAVMetaDataKey VOAVMetaDataKeyForced       = @"FORCED";
VOAVMetaDataKey VOAVMetaDataKeyVideoRange   = @"VIDEO-RANGE";


@interface VOAVTrackInfo()
{
@protected
    NSMutableDictionary *propertyDict;
}

@end

@implementation VOAVTrackInfo

- (instancetype)initWithKeyValueString:(NSString *)string
{
    if (self = [super init]) {
        [string test2];
        propertyDict = [string parserToDictionary];
    }
    
    return self;
}

+ (VOAVTrackInfo *)trackInfoWithString:(NSString *)string
{
    Class class;
    NSString *tag;
    if ([string hasPrefix:M3U8_TAG_MASTER_MEDIA]) {
        tag = M3U8_TAG_MASTER_MEDIA;
        class = [VOAVTrackInfoMedia class];
    } else if ([string hasPrefix:M3U8_TAG_MASTER_STREAM]) {
        tag = M3U8_TAG_MASTER_STREAM;
        class = [VOAVTrackInfoStream class];
    } else if ([string hasPrefix:M3U8_TAG_MASTER_STREAM_IFRAME]) {
        tag = M3U8_TAG_MASTER_STREAM_IFRAME;
        class = [VOAVTrackInfoIframe class];
    } else {
        return nil;
    }

    string = [string stringByReplacingOccurrencesOfString:tag withString:@""];

    if (![class isSubclassOfClass:[VOAVTrackInfo class]]) {
        return nil;
    }

    return [[class alloc] initWithKeyValueString:string];
}

- (NSString *)getTrackTag
{
    return nil;
}

- (NSString *)getPropertyValue:(VOAVMetaDataKey)key
{
    return propertyDict[key];
}

- (VOAVTrackType)type
{
    return propertyDict[VOAVMetaDataKeyType];
}

- (VOAVMetaDataKey)language
{
    return propertyDict[VOAVMetaDataKeyLanguage];
}

- (void)setLanguage:(NSString *)language
{
    updateProperty(VOAVMetaDataKeyLanguage,language);
}

- (NSString *)makeString
{
    NSString *tag = [self getTrackTag];
    if (tag == nil) {
        return nil;
    }
    
    NSMutableString *string = [NSMutableString stringWithString:tag];
    
    for (NSString *property in propertyDict.allKeys) {
        NSString *vaule = propertyDict[property];
        if (vaule == nil) {
            continue;
        }
        
        [string appendFormat:M3U8_KEY_VALUE_FORMAT,property,vaule];
    }

    
    if ([string hasSuffix:@","]) {
        deleteLastChar(string);
    }
    
    return string;
}

- (void)addRelativePath:(NSString *)relativePath
{
    NSString *pathComponent = [propertyDict[VOAVMetaDataKeyURI] stringByTrimDoubleQuotationMarks];
    if (pathComponent == nil) {
        return;
    }
    NSString *absolutePath = [[NSString absoluteURLPath:relativePath pathComponent:pathComponent] stringByAddingDoubleQuotationMarks];
    [propertyDict setObject:absolutePath forKey:VOAVMetaDataKeyURI];
}

@end

@implementation VOAVTrackInfoMedia

- (NSString *)getTrackTag
{
    return M3U8_TAG_MASTER_MEDIA;
}

- (VOAVMetaDataKey)language
{
    return propertyDict[VOAVMetaDataKeyLanguage];
}

- (void)specifyAsDefaultSelection:(BOOL)isDefault
{
    updateProperty(VOAVMetaDataKeyDefault,@"YES");
    updateProperty(VOAVMetaDataKeyAutoSelect,@"YES");
}

@end

/*******************************************************
 *
    VOAVTrackInfoIframe
 *
 *******************************************************/

VOAVMetaDataKey VOAVMetaDataKeyProgramID   = @"PROGRAM-ID";
VOAVMetaDataKey VOAVMetaDataKeyBandwidth   = @"BANDWIDTH";
VOAVMetaDataKey VOAVMetaDataKeyCodecs      = @"CODECS";

@implementation VOAVTrackInfoIframe

- (NSString *)getTrackTag
{
    return M3U8_TAG_MASTER_STREAM_IFRAME;
}

- (VOAVTrackType)type
{
    return VOAVTrackTypeIFrame;
}

- (VOAVMetaDataKey)language
{
    return propertyDict[VOAVMetaDataKeyLanguage];
}
@end


/*******************************************************
 *
    VOAVTrackInfoSteam
 *
 *******************************************************/

VOAVMetaDataKey VOAVMetaDataKeyResolution   = @"RESOLUTION";
VOAVMetaDataKey VOAVMetaDataKeyAudio        = @"AUDIO";
VOAVMetaDataKey VOAVMetaDataKeySubtitles    = @"SUBTITLES";
VOAVMetaDataKey VOAVMetaDataKeyFrameRate    = @"FRAME-RATE";

@implementation VOAVTrackInfoStream

- (NSString *)getTrackTag
{
    return M3U8_TAG_MASTER_STREAM;
}

- (VOAVTrackType)type
{
    return VOAVTrackTypeVideo;
}

- (VOAVMetaDataKey)language
{
    return propertyDict[VOAVMetaDataKeyLanguage];
}

- (void)addRelativePath:(NSString *)relativePath
{
    NSString *absolutePath = [NSString absoluteURLPath:relativePath pathComponent:_URI];
    self.URI = absolutePath;
}

- (NSString *)makeString
{
    NSString *string = [super makeString];

    return [string stringByAppendingFormat:@"\n%@\r",self.URI];
}

- (void)setURI:(NSString *)URI
{
    _URI = URI;
}

//- (void)specifySubtitle:(NSString *)subtitleGroupID
//{
//    updateProperty(VOAVMetaDataKeySubtitles, subtitleGroupID);
//}

@end
