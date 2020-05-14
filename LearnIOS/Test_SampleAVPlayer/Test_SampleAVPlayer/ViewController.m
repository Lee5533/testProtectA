//
//  ViewController.m
//  Test_SampleAVPlayer
//
//  Created by Lee Li on 2019/8/5.
//  Copyright © 2019 Lee Li. All rights reserved.
//

#import "ViewController.h"
#import "PlayerManager.h"

@interface ViewController () <PlayerManagerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *pauseOrPlay;
@property (strong, nonatomic) IBOutlet UISlider *playerSlide;
@property (strong, nonatomic) IBOutlet UILabel *currentPositionLabel;
@property (strong, nonatomic) IBOutlet UILabel *rangeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // test
    [SharedPlayerManager test];
    
    PlayerManager *playerManager = SharedPlayerManager;
    playerManager.parentView = self.view;
    
    [SharedPlayerManager createUI];
    [SharedPlayerManager createPlayer];
    
    [self.pauseOrPlay setTitle:@"pause" forState:UIControlStateNormal];
    
    //注册通知 并且接收通知    添加一个观察者，可以为它指定一个方法，名字和对象。接受到通知时，执行方法。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(getNotification:)
                                          name:nil
                                          object:nil];
}

- (IBAction)pauseOrPlay:(id)sender {
    [SharedPlayerManager playOrPause];
}

//接收到通知的操作
- (void)getNotification:(NSNotification *)notification {
    
    if ([notification.name isEqualToString:@"AVPlayerPlaybackRateObservationContext"])
    {
        
        NSString *status = notification.userInfo[@"data"];
        NSLog(@"ui rate :%@",status);

        if ([status  isEqual: @"pause"]) {
            [self.pauseOrPlay setTitle:@"play" forState:UIControlStateNormal];
        }
        else{
            [self.pauseOrPlay setTitle:@"pause" forState:UIControlStateNormal];
        }
    }
    else if ([@"AVPlayerStatusReadyToPlay"  isEqual: notification.name])
    {
        
        NSLog(@"AVPlayerStatusReadyToPlay");
        
    }
    else if ([@"VOAVPlayerFailedNotification"  isEqual: notification.name])
    {
        
        NSLog(@"VOAVPlayerFailedNotification");
        
        
    }
}

- (void)player:(AVPlayer *)player positionUpdate:(PlayerPosition)playerPosition
{
    NSLog(@"ui positionUpdate");
    self.currentPositionLabel.text = [self getTimeFormatString:playerPosition.current];
    
    self.playerSlide.hidden = NO;
    self.playerSlide.value = playerPosition.current * 1.0f / playerPosition.duration;
    self.rangeLabel.text = [NSString stringWithFormat:@"%@/%@",
                            [self getTimeFormatString:playerPosition.start],
                            [self getTimeFormatString:playerPosition.duration]];
}

//#pragma mark private
- (NSString *)getTimeFormatString:(long long)seconds
{
    NSString* str = @"";
    if (0 > seconds) {
        seconds = -seconds;
        str = @"-";
    }
    
    return [NSString stringWithFormat:@"%@%02lld:%02lld:%02lld", str, seconds / 3600,seconds % 3600 / 60,seconds % 3600 % 60];
}

- (IBAction)pipBtnClick:(id)sender {
    NSLog(@"lee pipBtnClick\n");
    [SharedPlayerManager pipControllerClick];
}

- (IBAction)replaceItemBtn:(id)sender {
     NSLog(@"lee replaceItemBtnClick\n");
    [SharedPlayerManager doReplaceURL];
}

@end
