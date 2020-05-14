//
//  testClass.m
//  Test_SampleAVPlayer
//
//  Created by Lee Li on 2019/8/7.
//  Copyright © 2019 Lee Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "testClass.h"

@implementation testClass

- (void)testdelegate {
    NSLog(@"yes, sir.I am test:");
}

- (void)player:(AVPlayer *)player positionUpdate:(PlayerPosition)playerPosition {
    NSLog(@"yes, sir.I am positionUpdate:");
}


@end
