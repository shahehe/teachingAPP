//
//  YRecorder.m
//  LetterB
//
//  Created by Yan Feng on 3/22/14.
//  Copyright (c) 2014 USTB. All rights reserved.
//

#import "YRecorder.h"

@implementation YRecorder
@synthesize currWav;
@synthesize recorder;
@synthesize player;
@synthesize session;
static YRecorder * engine = nil;
//-(void) setDelegate:(id)delegate
//{
//    [player setDelegate:delegate];
//}
NSMutableDictionary *recordSetting;
- (id)init
{
    if (self = [super init])
    {
        // Initialization code here.
        session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        // Define the recorder setting
        recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:16000] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
        //  [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        
        recorder = nil;
        

    }
    return self;
}

+(YRecorder *)sharedEngine
{
    if ( engine == nil)
    {
          engine = [[super allocWithZone:NULL] init];
        
    }
    return engine;
}
-(void) record
{
    if ( recorder )
    {
        [recorder stop];
        [recorder release];
        recorder = nil;
    }
    // Initiate and prepare the recorder
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString * timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    NSURL *audioURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.wav",documentDirectory,timeStampValue]];
    
    
    currWav = [[NSString alloc] initWithFormat:@"%@/%@.wav",documentDirectory,timeStampValue];
    NSError * error = nil;

    recorder = [[AVAudioRecorder alloc] initWithURL:audioURL settings:recordSetting error:&error];
    
    
    
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
    [recorder record];
}
-(NSString *) getWaveFileName
{
    return currWav;
}
-(void) play
{
    [player stop];
    [player setCurrentTime:0.0];
    [player release];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
    //[player setDelegate:self];
    [player setDelegate:_delegate];

    [player play];
}
-(void) stop
{
    [recorder stop];
}
// singleton methods
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedEngine] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  // denotes an object that cannot be released
}


- (id)autorelease {
    return self;
}

-(void)dealloc {
    [super dealloc];
}
@end
