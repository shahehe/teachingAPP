//
//  LearnWordGameLayer.h
//  BookReader
//
//  Created by USTB on 12-10-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "cocos2d.h"
#import "Color.h"

#import "PhonicsGameLayer.h"

#define FONTNAME @"Cooper Black"
#define FONTSIZE 80
#define CANDIDATE 8

@interface LearnWord : PhonicsGameLayer <AVAudioPlayerDelegate>
{
    //Cards
    NSUInteger cardCount; //卡片总数
    NSUInteger currentCardIndex;     //当前卡片序号
    
    NSArray *cards;//retained
    
    //words
    //NSArray *letterIndex;//retained.example:1,3
    //CCArray *letterLabels;//retained
    CCArray *waitingLetterLabels;
    
    //NSMutableArray *candidateLetters;
    CCArray *candidateLetterLabels;
    
    CCProgressTimer *gradientLabelTimer;
    ccColor3B gradientColor;
    ccColor3B bgColor;
    
    //touch & move
    int isBeingTouchedLabelIndex;
    
    //Audio Player
    AVAudioPlayer *_player;
    
    //pause?
    BOOL _isPaused;
    
    CCNode *allLabel;
    CCSprite *board;
    CCSprite *monster;
    
    // time duration
    CGFloat time;
}

@property(nonatomic,assign) AVAudioPlayer *player;
@property(readwrite) BOOL isPaused;

//+ (CCScene *)scene;

- (void) pause;

- (void) play;

@end

@interface NSString (yiplee)

- (void) printSelf;

- (ccColor3B) string2ColorWithDefaultColor:(ccColor3B) defaultColor;

@end
