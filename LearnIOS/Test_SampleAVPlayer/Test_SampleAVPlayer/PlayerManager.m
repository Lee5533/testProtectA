//
//  PlayerManager.m
//  Test_SampleAVPlayer
//
//  Created by Lee Li on 2019/8/5.
//  Copyright © 2019 Lee Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerManager.h"
#import <objc/runtime.h>
#import <MediaPlayer/MediaPlayer.h>



@implementation PlayerManager
static PlayerManager *defaultManager = nil;
#pragma mark
+ (id)sharedInstance
{
//    //创建单例实例
//    Class selfClass = [self class];
//    id instance = objc_getAssociatedObject(selfClass, @"kOTSharedInstance");
//    if (!instance)
//    {
//        instance = [[selfClass alloc] init];
//        objc_setAssociatedObject(selfClass, @"kOTSharedInstance", instance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return instance;

    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil)
        {
            defaultManager = [[self alloc] init];
        }
    });
    return defaultManager;
}

- (void)createUI {
    //构建ui
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 300, 300)];
    self.backView.backgroundColor = [UIColor clearColor];//clearColor
    [self.parentView addSubview:self.backView];
    [self addAirPlay];
    self.a1 = false;
}

- (void)addAirPlay
{
    MPVolumeView *volume = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 100, 44, 44)];
    volume.showsVolumeSlider = NO;
    [volume sizeToFit];
    volume.backgroundColor = [UIColor grayColor];
    [self.parentView addSubview:volume];
}

- (void)createPlayer {
    
    // 初始化播放器item//
    NSURL *url = [NSURL URLWithString:@"http://stream1.visualon.com:8082/hls/v10/gear/bipbop_16x9_variant_v10_2.m3u8"];
//    NSURL *url = [NSURL URLWithString:@"https://act1.video.friday.tw/20190924/playlist.m3u8"];
//    NSURL *url = [NSURL URLWithString:@"http://dg-live.world.edge001.int1-dus.dg-m.de/cnn/live.isml/live.m3u8?dvr_window_length=600"];
//    NSURL *url = [NSURL URLWithString:@"http://192.168.31.74/download/chunk5s/ts_internal.m3u8"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
    // 初始化播放器的Layer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.backView.bounds;
    
    [self.backView.layer insertSublayer:self.playerLayer atIndex:0];
    //播放
    [self addPlayerItemObserver];
    [self addPlayerObserver];
//    [self.player play];
    [self setupSuportPIP];
}

- (void)doReplaceURL
{
    NSLog(@"lee doReplaceURL--start\n");
    if (self.player)
        {
            NSURL *sourceURL = [NSURL URLWithString:@"http://dg-live.world.edge001.int1-dus.dg-m.de/cnn/live.isml/live.m3u8?dvr_window_length=600"];
            AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
            
            [self removePlayerItemObserver];
            self.playerItem = [AVPlayerItem playerItemWithAsset:sourceAsset];
                                
            if (self.player.currentItem != self.playerItem)
            {
                [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
            }
            
            [self addPlayerItemObserver];
        }
    NSLog(@"lee doReplaceURL--end\n");
}

#pragma mark player manage opration
- (void)playOrPause
{
    if (self.player.rate != .0f) {
        [self.player pause];
    }
    else {
        [self.player play];
    }
}

//test
- (void)payOff {
    NSLog(@"yes, sir.I will pay off:%@",self.test);
    self.test = @"hi Lee";
}


#pragma mark add/remove  PlayerItemObserver and PlayerObserver
- (void)addPlayerItemObserver
{
    if (nil == self.playerItem) {
        return;
    }
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:@"AVPlayerPlaybackStatusObservationContext"];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackBufferEmpty"
                         options:NSKeyValueObservingOptionNew
                         context:@"AVPlayerPlaybackPlaybackEmptyObservationContext"];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackLikelyToKeepUp"
                         options:NSKeyValueObservingOptionNew
                         context:@"AVPlayerPlaybackPlaybackLikelyToKeepUpObservationContext"];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackBufferFull"
                         options:NSKeyValueObservingOptionNew
                         context:@"AVPlayerPlaybackPlaybackBufferFullObservationContext"];
    
    //    [self.playerItem addObserver:self
    //                  forKeyPath:kVOCurrentMediaSelection
    //                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
    //                     context:AVPlayerPlaybackCurrentMediaSelectionObservationContext];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"tracks"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:@"AVPlayerPlaybackTracksObservationContext"];
    
    
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

}

- (void)removePlayerItemObserver
{
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.playerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
        //        [self.playerItem removeObserver:self forKeyPath:kVOCurrentMediaSelection];
        [self.playerItem removeObserver:self forKeyPath:@"tracks"];
        
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
                  forKeyPath:@"currentItem"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:@"AVPlayerPlaybackCurrentItemObservationContext"];
    
    /* Observe the AVPlayer "rate" property to update the scrubber control. */
    [self.player addObserver:self
                  forKeyPath:@"rate"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:@"AVPlayerPlaybackRateObservationContext"];
    
    [self.player addObserver:self
                  forKeyPath:@"externalPlaybackActive"
                     options:NSKeyValueObservingOptionNew
                     context:@"AVPlayerPlaybackAirPlayActiveObservationContext"];
}

- (void)removePlayerObserver
{
    if (nil == self.player) {
        return;
    }
    
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player removeObserver:self forKeyPath:@"currentItem"];
    [self.player removeObserver:self forKeyPath:@"externalPlaybackActive"];
}


- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == @"AVPlayerPlaybackStatusObservationContext")
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
                [self addTimeObserve];
                //ios13 pip will close after replaceCurrentItemWithPlayerItem
                /*
                [self.pipController startPictureInPicture];
                NSLog(@"lee AVPlayerStatusReadyToPlay--start pip\n");
                 */
                                
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
    else if (context == @"AVPlayerPlaybackPlaybackEmptyObservationContext")
    {

        if (object == self.playerItem && [path isEqualToString:@"playbackBufferEmpty"])
        {
            NSLog(@"lee playbackBufferEmpty--\n");
        }
        else if (object == self.playerItem && ([path isEqualToString:@"playbackLikelyToKeepUp"] || [path isEqualToString:@"playbackBufferFull"]))
        {
            NSLog(@"lee playbackLikelyToKeepUp--\n");
        }
    }
    else if ((context == @"AVPlayerPlaybackPlaybackLikelyToKeepUpObservationContext")
             || (@"AVPlayerPlaybackPlaybackBufferFullObservationContext" == context))
    {
        
    }
    else if (context == @"AVPlayerPlaybackCurrentMediaSelectionObservationContext")
    {

    }
    else if (context == @"AVPlayerPlaybackTracksObservationContext")
    {
        
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == @"AVPlayerPlaybackRateObservationContext")
    {
        NSString *status = @"pause";
        float newRate = [change[NSKeyValueChangeNewKey] floatValue];
        float oldRate = [change[NSKeyValueChangeOldKey] floatValue];
        
        if (newRate == 0.0f)
        {
            status = @"pause";
        }
        else
        {
            status = @"play";
        }
        
        NSLog(@"Rate: %.1f -> %.1f",oldRate, newRate);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AVPlayerPlaybackRateObservationContext" object:nil userInfo:@{@"data":status}];
    }
    else if (context == @"AVPlayerPlaybackAirPlayActiveObservationContext")
    {
       
    }
    else if (context == @"AVPlayerPlaybackCurrentItemObservationContext")
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

- (void)addTimeObserve
{
    self.timerInvalid = NO;
    
    __weak typeof(self)weakSelf = self;
    self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        if (weakSelf.timerInvalid) {
            return;
        }
        
        CMTime currentTime = [weakSelf.player currentTime];
        
        NSArray* loadedRanges = weakSelf.player.currentItem.seekableTimeRanges;
        if ((nil != loadedRanges) && loadedRanges.count > 0)
        {
            CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
            Float64 duration = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
            
//            NSLog(@"duration:%f\n",duration);
            if (!CMTIME_IS_VALID(range.duration) || 0 >= duration) {
                return;
            }
            
            /* The playToEnd notification only receive once, so detect the playing position */
            /*
            if (self.loopMode == PLAYBACK_LOOP_MODE_SINGLE_LOOP) {
                double dist = CMTimeGetSeconds(range.duration) - CMTimeGetSeconds(currentTime);
                if (dist < MIN_END_DIST) {
                    [weakSelf playFromHead];
                    weakSelf.timerInvalid = YES;
                }
            }
            */
            
            PlayerPosition position = {
                .start = CMTimeGetSeconds(range.start),
                .duration = duration,
                .current = CMTimeGetSeconds(currentTime)
            };
//            NSLog(@"duration:%ld\n",(long)position.current);
            
            [weakSelf.delegate player:weakSelf.player positionUpdate:position];
            
            //10s auto replace url;
            /*
            if ((long)position.current > 10 && !self.a1){
                [weakSelf doReplaceURL];
                self.a1 = true;
            }
             */
        }
    }];
}

//-(void)removePlayerTimeObserver
//{
//    if (self.player && m_timeObserver)
//    {
//
//        [self.player removeTimeObserver: m_timeObserver];
//        [m_timeObserver release];
//        m_timeObserver = nil;
//    }
//}

#pragma mark player support PIP (pictureInPicture)
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

- (void)pipControllerSuspend
{
    [self.pipController startPictureInPicture];
    NSLog(@"lee pipSuspend--start\n");
}

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
//监听pip
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler{
    printf("lee restoreUser\n");
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    printf("lee DidStop\n");
}
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    printf("lee DidStart\n");
    
}
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    printf("lee WillStop\n");
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error{
    printf("lee failedToStart\n");
}
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController{
    printf("lee WillStart\n");
}
//
@end
