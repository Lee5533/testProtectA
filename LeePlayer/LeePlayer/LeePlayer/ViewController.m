//
//  ViewController.m
//  LeePlayer
//
//  Created by Lee Li on 2020/7/20.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#import "ViewController.h"
#import "playerManager.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *pauseOrPlay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"lee hello test\n");
//    playerManager *player = [[playerManager alloc]init];
    
    playerManager *player = SharedPlayerManager;
    player.parentView = self.view;
    
    [SharedPlayerManager createUI];
    [SharedPlayerManager createPlayer];
    
    [self.pauseOrPlay setTitle:@"pause" forState:UIControlStateNormal];
    //注册通知 并且接收通知    添加一个观察者，可以为它指定一个方法，名字和对象。接受到通知时，执行方法。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(getNotification:)
                                          name:nil
                                          object:nil];
}
- (IBAction)pipBtn:(id)sender {
    NSLog(@"lee pip BtnClick\n");
    [SharedPlayerManager pipControllerClick];
}
- (IBAction)playOrPause:(id)sender {
    NSLog(@"lee playOrPause BtnClick\n");
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

@end
