//
//  PlayerManager.h
//  Test_SampleAVPlayer
//
//  Created by Lee Li on 2019/8/5.
//  Copyright © 2019 Lee Li. All rights reserved.
//

#ifndef PlayerManager_h
#define PlayerManager_h

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
#import <UIKit/UIKit.h>
#import <AVKit/AVPictureInPictureController.h>

#define SharedPlayerManager [PlayerManager sharedInstance]

typedef struct {
    NSInteger start;
    NSInteger duration;
    NSInteger current;
} PlayerPosition;

@protocol PlayerManagerDelegate;

@interface PlayerManager : NSObject

@property (nonatomic, weak)id <PlayerManagerDelegate>  delegate;
@property (nonatomic, strong) UIView  *parentView;
@property (strong, nonatomic) UIView  *backView;

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) NSString  *test;
@property (nonatomic, strong, readonly)NSString *version;

@property (nonatomic, assign)BOOL timerInvalid;
@property (nonatomic, strong)id playerObserver;
@property (nonatomic, retain) AVPictureInPictureController *pipController;
@property (nonatomic, assign)  bool a1;

+ (id)sharedInstance;

- (void)createUI;

- (void)addAirPlay;

- (void)createPlayer;

- (void)doReplaceURL;

- (void)playOrPause;

- (void)payOff;

- (void)player:(AVPlayer *)player positionUpdate:(PlayerPosition)playerPosition;

- (void)pipControllerClick;

- (void)pipControllerSuspend;

@end


@protocol PlayerManagerDelegate <NSObject>

- (void)player:(AVPlayer *)player positionUpdate:(PlayerPosition)playerPosition;
- (void)testdelegate;

@end
#endif /* PlayerManager_h */
