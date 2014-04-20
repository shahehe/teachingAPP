//
//  YRecorder.h
//  LetterB
//
//  Created by Yan Feng on 3/22/14.
//  Copyright (c) 2014 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface YRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
+ (YRecorder *) sharedEngine;
-(void) record;
-(void) play;
-(void) stop;
-(NSString *) getWaveFileName;
//-(void) setDelegate:(id)delegate;
@property (nonatomic, strong) NSString * currWav;
@property (nonatomic,strong)  AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioSession * session;

@property(nonatomic,assign) id<AVAudioPlayerDelegate> delegate;

@end
