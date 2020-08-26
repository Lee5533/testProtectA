//
//  playerManager.m
//  LeePlayer
//
//  Created by Lee Li on 2020/7/20.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "playerManager.h"
#import "baseSocket.hpp"

#define observerContext(context) static void *context = &context;

/* PlayerItem keys */
NSString * const LeaStatusKey                 = @"status";
NSString * const leaPlaybackBufferEmpty       = @"playbackBufferEmpty";
NSString * const leaPlaybackLikelyToKeepUp    = @"playbackLikelyToKeepUp";
NSString * const leaPlaybackBufferFull        = @"playbackBufferFull";
NSString * const leaTracks                    = @"tracks";
NSString * const leaPresentationSize          = @"presentationSize";

/* AVPlayer keys */
NSString * const leaRateKey                   = @"rate";
NSString * const leaCurrentItem               = @"currentItem";
NSString * const leaAirplay                   = @"externalPlaybackActive";

/* PlayerItem context */
observerContext(AVPlayerPlaybackStatusObservationContext);
observerContext(AVPlayerPlaybackPlaybackEmptyObservationContext);
observerContext(AVPlayerPlaybackPlaybackLikelyToKeepUpObservationContext);
observerContext(AVPlayerPlaybackPlaybackBufferFullObservationContext);
observerContext(AVPlayerPlaybackTracksObservationContext);

/* Player context */
observerContext(AVPlayerPlaybackCurrentItemObservationContext);
observerContext(AVPlayerPlaybackRateObservationContext);
observerContext(AVPlayerPlaybackAirPlayActiveObservationContext);

@implementation playerManager
static playerManager *defaultManager = nil;
+ (id)sharedInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil)
        {
            defaultManager = [[self alloc] init];
        }
    });
    return defaultManager;
}
-(void)test
{
    NSLog(@"lee playerManager test");
//    baseSocket *tmp = new baseSocket();
//    self.baseTemp = (void *)tmp;
//    tmp->test();
    
    
    
//     NSLog(@"lee playerManager test:%d",self.baseTemp->na);
    
}

- (void)createUI {
    //构建ui
//    [self test];
    NSLog(@"lee player create ui");
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 500, 500)];
    self.backView.backgroundColor = [UIColor clearColor];//clearColor
    [self.parentView addSubview:self.backView];
    
    
}

- (void)createPlayer {
//    baseSocket *tmp1 = (baseSocket *)self.baseTemp;
//
//    tmp1->test();
    
    NSLog(@"lee player create player");
    // 初始化播放器item//
    NSURL *url = [NSURL URLWithString:@"http://stream1.visualon.com:8082/hls/v10/gear/bipbop_16x9_variant_v10_2.m3u8"];
//    NSURL *url = [NSURL URLWithString:@"https://act1.video.friday.tw/20190924/playlist.m3u8"];
//    NSURL *url = [NSURL URLWithString:@"http://dg-live.world.edge001.int1-dus.dg-m.de/cnn/live.isml/live.m3u8?dvr_window_length=600"];
//    NSURL *url = [NSURL URLWithString:@"http://192.168.31.74/download/chunk5s/ts_internal.m3u8"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
//    self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    
    // 初始化播放器的Layer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.backView.bounds;
    
    [self.backView.layer insertSublayer:self.playerLayer atIndex:0];
    //播放
    [self addPlayerItemObserver];
    [self addPlayerObserver];
    [self.player play];
    [self setupSuportPIP];
}

#pragma mark add/remove  PlayerItemObserver and PlayerObserver
- (void)addPlayerItemObserver
{
    if (nil == self.playerItem) {
        return;
    }
    [self.playerItem addObserver:self
                      forKeyPath:LeaStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerPlaybackStatusObservationContext];
    
    [self.playerItem addObserver:self
                      forKeyPath:leaPlaybackBufferEmpty
                         options:NSKeyValueObservingOptionNew
                         context:AVPlayerPlaybackPlaybackEmptyObservationContext];
    
    [self.playerItem addObserver:self
                      forKeyPath:leaPlaybackLikelyToKeepUp
                         options:NSKeyValueObservingOptionNew
                         context:AVPlayerPlaybackPlaybackLikelyToKeepUpObservationContext];
    
    [self.playerItem addObserver:self
                      forKeyPath:leaPlaybackBufferFull
                         options:NSKeyValueObservingOptionNew
                         context:AVPlayerPlaybackPlaybackBufferFullObservationContext];
    
    //    [self.playerItem addObserver:self
    //                  forKeyPath:kVOCurrentMediaSelection
    //                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
    //                     context:AVPlayerPlaybackCurrentMediaSelectionObservationContext];
    
    [self.playerItem addObserver:self
                      forKeyPath:leaTracks
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerPlaybackTracksObservationContext];
    
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDiscontinue:)
                                                 name:AVPlayerItemTimeJumpedNotification
                                               object:self.playerItem];

    [self registerForall];
}

-(void)registerForall
{
    //Screen lock notifications
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    (void *)self, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.iokit.hid.displayStatus"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);


    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    (void *)self, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.springboard.lockstate"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    (void *)self, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.springboard.hasBlankedScreen"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    (void *)self, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.springboard.lockcomplete"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

}
//call back
void displayStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    playerManager *mgr = (__bridge playerManager *)observer;
//    mgr.bStateLocked
    NSLog(@"IN Display status changed");
    NSLog(@"Darwin notification NAME = %@",name);
    
    NSString* lockState = (__bridge NSString*)name;
//    if ([lockstate isEqualToString:(__bridge  NSString*)kNotificationLock])
    if([lockState isEqualToString:@"com.apple.springboard.lockcomplete"])
    {
        mgr.bStateLocked = YES;
        NSLog(@"lee lock 锁屏");
        mgr.playerStateBeforeLocked = mgr.playerState;
    }
    else if([lockState isEqualToString:@"com.apple.iokit.hid.displayStatus"])
    {
//        if (mgr.bStateLocked) {
//            mgr.bStateLocked = NO;
//        }else{
//            NSLog(@"lee lock 解锁");
//        }
        if (mgr.bStateLocked)
        {
            NSLog(@"lee lock 解锁");
        }
    }


}
-(void)readyToPlay
{
}
- (void)removePlayerItemObserver
{
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.playerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        [self.playerItem removeObserver:self forKeyPath:LeaStatusKey];
        [self.playerItem removeObserver:self forKeyPath:leaPlaybackBufferEmpty];
        [self.playerItem removeObserver:self forKeyPath:leaPlaybackLikelyToKeepUp];
        [self.playerItem removeObserver:self forKeyPath:leaPlaybackBufferFull];
        //        [self.playerItem removeObserver:self forKeyPath:kVOCurrentMediaSelection];
        [self.playerItem removeObserver:self forKeyPath:leaTracks];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemTimeJumpedNotification
                                                      object:self.playerItem];
    }
    self.playerItem = nil;
}

- (void)addPlayerObserver
{
    if (nil == self.player) {
        return;
    }
    
    /* Observe the AVPlayer "currentItem" property to find out when any
     AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
     occur.*/
    [self.player addObserver:self
                  forKeyPath:leaCurrentItem
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerPlaybackCurrentItemObservationContext];
    
    /* Observe the AVPlayer "rate" property to update the scrubber control. */
    [self.player addObserver:self
                  forKeyPath:leaRateKey
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerPlaybackRateObservationContext];
    
    [self.player addObserver:self
                  forKeyPath:leaAirplay
                     options:NSKeyValueObservingOptionNew
                     context:AVPlayerPlaybackAirPlayActiveObservationContext];
}

- (void)removePlayerObserver
{
    if (nil == self.player) {
        return;
    }
    
    [self.player removeObserver:self forKeyPath:leaRateKey];
    [self.player removeObserver:self forKeyPath:leaCurrentItem];
    [self.player removeObserver:self forKeyPath:leaAirplay];
}


- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == AVPlayerPlaybackStatusObservationContext)
    {
        AVPlayerStatus status = (AVPlayerStatus)[[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"lee AVPlayerStatusUnknown");
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AVPlayerStatusReadyToPlay" object:nil userInfo:@{@"data":@"asd"}];
//                [self.notificationCenter postNotificationName:VOAVPlayerReadyToPlayNotification object:self];
//                [self addTimeObserve];
                //ios13 pip will close after replaceCurrentItemWithPlayerItem
                /*
                [self.pipController startPictureInPicture];
                NSLog(@"lee AVPlayerStatusReadyToPlay--start pip\n");
                 */
                NSLog(@"lee AVPlayerStatusReadyToPlay bStateLocked:%d,_playerStateBeforeLocked:%d\n",self.bStateLocked,_playerStateBeforeLocked);
                if (self.bStateLocked && _playerStateBeforeLocked == AVStatePlaying)
                {
                    [self.player play];
                    self.bStateLocked = NO;
                }
                
            }
                break;
            case AVPlayerStatusFailed:
            {
                NSLog(@"lee AVPlayerStatusFailed");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VOAVPlayerFailedNotification" object:self];
                
                NSString *errorInfo = [NSString stringWithFormat:@"reportFailed localizedDescription:%@ localizedFailureReason:%@", [self.player.error localizedDescription], [self.player.error localizedFailureReason]];
                NSLog(@"%@",errorInfo);
            }
                break;
        }
    }
    else if (context == AVPlayerPlaybackPlaybackEmptyObservationContext)
    {

        if (object == self.playerItem && [path isEqualToString:leaPlaybackBufferEmpty])
        {
            NSLog(@"lee playbackBufferEmpty--\n");
        }
        else if (object == self.playerItem && ([path isEqualToString:leaPlaybackLikelyToKeepUp] || [path isEqualToString:leaPlaybackBufferFull]))
        {
            NSLog(@"lee playbackLikelyToKeepUp--\n");
        }
    }
    else if ((context == AVPlayerPlaybackPlaybackLikelyToKeepUpObservationContext)
             || (AVPlayerPlaybackPlaybackBufferFullObservationContext == context))
    {
        
    }
    else if (context == @"AVPlayerPlaybackCurrentMediaSelectionObservationContext")
    {

    }
    else if (context == AVPlayerPlaybackTracksObservationContext)
    {
        
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == AVPlayerPlaybackRateObservationContext)
    {
        NSString *status = @"pause";
        float newRate = [change[NSKeyValueChangeNewKey] floatValue];
        float oldRate = [change[NSKeyValueChangeOldKey] floatValue];
        
        if (newRate == 0.0f)
        {
            status = @"pause";
            self.playerState = AVStatePaused;
        }
        else
        {
            status = @"play";
            self.playerState = AVStatePlaying;
        }
        
        NSLog(@"Rate: %.1f -> %.1f",oldRate, newRate);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AVPlayerPlaybackRateObservationContext" object:nil userInfo:@{@"data":status}];
    }
    else if (context == AVPlayerPlaybackAirPlayActiveObservationContext)
    {
       
    }
    else if (context == AVPlayerPlaybackCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        NSLog(@"%s", newPlayerItem.description.UTF8String);
        
        return;
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}


- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    //todo
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationName" object:nil userInfo:@{@"data":@"asd"}];
}

- (void)playerItemDiscontinue:(NSNotification *)notification
{

    //todo
}

#pragma mark player support PIP (pictureInPicture)
//support pip
-(void)setupSuportPIP
{
    if([AVPictureInPictureController isPictureInPictureSupported])
    {
        printf("lee setupSuport\n");
        self.pipController =  [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
        self.pipController.delegate = self;
    }
    else
    {
        // not supported PIP start button desable here
    }
}

- (void)pipControllerSuspend
{
    [self.pipController startPictureInPicture];
    NSLog(@"lee pipSuspend--start\n");
}

- (void)pipControllerClick
{
    NSLog(@"lee pipBtnClick\n");
    
    if (self.pipController.pictureInPictureActive) {
        [self.pipController stopPictureInPicture];
    }
    else {
        [self.pipController startPictureInPicture];
         NSLog(@"lee pipBtnClick--start\n");
    }
}

//监听pip
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler{
    printf("lee native restoreUser\n");
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    printf("lee native DidStop\n");
}
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    printf("lee native DidStart\n");
    
}
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    printf("lee native WillStop\n");
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error{
    printf("lee native failedToStart\n");
}
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    printf("lee native WillStart\n");
}

#pragma mark player manage opration
- (void)playOrPause
{
    NSLog(@"lee playOrPause playerManager,rate:%f\n",self.player.rate);
    if (self.player.rate != .0f) {
        [self.player pause];
    }
    else {
        [self.player play];
    }
}
@end
