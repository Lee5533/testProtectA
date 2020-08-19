//
//  ViewController.m
//  audioUnitDemo
//
//  Created by Lee Li on 2020/8/11.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#import "ViewController.h"
//#import "AVFoundation.h";
//#import "AudioUnit.h";
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (nonatomic, copy) NSString *pathStr;
@end
@implementation ViewController

#define kOutputBus 0
#define kInputBus 1
AudioComponentInstance audioUnit;
//AudioUnit audioUnit;
FILE *file = NULL;
AVAudioSession *audioSession;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.pathStr = [self documentsPath:@"/mixRecord.pcm"];
    [self initAudioSession];
    [self myAudio];
    [NSThread sleepForTimeInterval:1];
//    exit(0);
}

- (IBAction)start:(id)sender
{
    OSErr iErrCode = AudioOutputUnitStart(audioUnit);
}
- (IBAction)stopBtn:(id)sender
{
    OSErr iErrCode = AudioOutputUnitStop(audioUnit);
}

#pragma mark - AudioUnitInitMethod
- (void)initAudioSession {
    audioSession = [AVAudioSession sharedInstance];

    NSError *error;
    // set Category for Play and Record
    // [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetoothA2DP error:&error];
     [audioSession setPreferredIOBufferDuration:0.01 error:&error];
}
- (NSString *)documentsPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)writePCMData:(char *)buffer size:(int)size {
    if (!file) {
        file = fopen(self.pathStr.UTF8String, "w");
    }
    fwrite(buffer, size, 1, file);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {

// This works, but can be optimised by moving this code out of the Callback function.

    AudioBufferList *bufferList;
    bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer));
    bufferList->mNumberBuffers = 1;
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[0].mDataByteSize = 1024 * 2;
    bufferList->mBuffers[0].mData = calloc(1024, 2);

    OSStatus status;
    ViewController *selfTmp = (__bridge ViewController*)inRefCon;
//    GSNAudioUnitGraph *THIS=(__bridge GSNAudioUnitGraph*)inRefCon;
    status = AudioUnitRender(audioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             bufferList);
    if (status != noErr) {
        NSLog(@"Error %ld", status);
    } else {
        NSLog(@"No Errors!");
        NSLog(@"data:%x, ",(int)*((SInt16 *)bufferList->mBuffers[0].mData));
    }

    // Now, we have the samples we just read sitting in buffers in bufferList
//     DoStuffWithTheRecordedAudio(bufferList);

//    [selfTmp writePCMData:bufferList size:sizeof(bufferList)];
    [selfTmp writePCMData:bufferList->mBuffers->mData size:bufferList->mBuffers->mDataByteSize];
//    [selfTmp writePCMData:ioData->mBuffers->mData size:ioData->mBuffers->mDataByteSize];
    return noErr;
}

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    return noErr;
}

- (void)myAudio {
    
    OSStatus status;
    

    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;

    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);

    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);

    

    UInt32 flag = 1;
#if 1
    // Disable IO for recording
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
#endif
    
    // Enable IO for playback  for render
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));

    // Describe format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate         = 44100.00;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mChannelsPerFrame   = 1;
    audioFormat.mBitsPerChannel     = 16;
    audioFormat.mBytesPerPacket     = 2;
    audioFormat.mBytesPerFrame      = 2;

    // Apply format
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    

    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    
    callbackStruct.inputProc = recordingCallback;
//    callbackStruct.inputProcRefCon = audioUnit;//self
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);//self
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));

     
    // Set output callback
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = audioUnit;//self
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));

    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    // Initialise
    status = AudioUnitInitialize(audioUnit);

    // Start
    status = AudioOutputUnitStart(audioUnit);
    NSLog(@"Starting returned code %ld", status);


    //    // It is not necessary to have a session, but if you have one, it must came after the setup of the audiounit.
    //    NSError *error = nil;
    //    // Configure & activate audio session
    //
    //    AVAudioSession *session = [AVAudioSession sharedInstance];
    //
    //    if (![session setCategory:AVAudioSessionCategoryRecord error:&error]) NSLog(@"Error configuring session category: %@", error);
    //    if (![session setMode:AVAudioSessionModeMeasurement error:&error]) NSLog(@"Error configuring session mode: %@", error);
    //    if (![session setActive:YES error:&error]) NSLog(@"Error activating audio session: %@", error);
    //
    //    NSLog(@"Session activated. sample rate %f", session.sampleRate);
    //    NSLog(@"Number of channels %d", session.inputNumberOfChannels);

}



@end
