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
+ (id)sharedInstance;

- (void)test;
- (void)createUI;
- (void)createPlayer;

#pragma mark player support PIP (pictureInPicture)
- (void)pipControllerClick;
- (void)pipControllerSuspend;

#pragma mark player manage opration
- (void)playOrPause;

@end

#endif /* playerManager_h */


