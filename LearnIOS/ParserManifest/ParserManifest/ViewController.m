//
//  ViewController.m
//  ParserManifest
//
//  Created by Lee Li on 2020/4/20.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#import "ViewController.h"
#import "m3u8.h"
@interface ViewController ()

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    printf("lee study");
    
    self.masterManifest = [VOAVM3u8Master alloc] ;
    [self.masterManifest test];
    NSArray<VOAVTrackInfo *> *videoList = [self.masterManifest getTrackGroup:VOAVTrackTypeAudio];
    for (VOAVTrackInfoStream *info in videoList) {

        printf("lee study2:%s,\n",[info.makeString UTF8String]);
    }
    
    printf("lee study3:%s,\n",[self.masterManifest.makeString UTF8String]);
    
}


@end
