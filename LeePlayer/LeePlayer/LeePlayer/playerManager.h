//
//  playerManager.h
//  LeePlayer
//
//  Created by Lee Li on 2020/7/20.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#ifndef playerManager_h
#define playerManager_h
#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import <AVKit/AVPictureInPictureController.h>

#define SharedPlayerManager [playerManager sharedInstance]

@interface playerManager : NSObject<AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) UIView  *parentView;
@property (strong, nonatomic) UIView  *backView;

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@property (nonatomic, retain) AVPictureInPictureController *pipController;

typedef NS_ENUM(NSUInteger, AVPlayerState) {
    AVStateIdle                        = 0x00000000,
    AVStateOpening                     = 0x00000001,
    AVStateReadyToPlay                 = 0x00000002,
    AVStatePlaying                     = 0x00000003,
    AVStateBuffering                   = 0x00000004,
    AVStateSeeking                     = 0x00000005,
    AVStatePaused                      = 0x00000006,
    AVStateStopped                     = 0x00000007
};

@property (nonatomic, assign) AVPlayerState playerStateBeforeLocked;
@property (nonatomic, assign) AVPlayerState playerState;
@property (nonatomic, assign) BOOL bStateLocked;

@property (nonatomic, assign) void  *baseTemp;

+ (id)sharedInstance;

- (void)test;
- (void)createUI;
- (void)createPlayer;
- (void)readyToPlay;

#pragma mark player support PIP (pictureInPicture)
- (void)pipControllerClick;
- (void)pipControllerSuspend;

#pragma mark player manage opration
- (void)playOrPause;

@end

#endif /* playerManager_h */


