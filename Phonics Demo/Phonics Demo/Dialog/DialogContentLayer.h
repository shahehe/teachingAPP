//
//  DialogContentLayer.h
//  Phonics Demo
//
//  Created by yiplee on 13-8-3.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import "cocos2d.h"
#import "ToolbarLayer.h"
#import "CLDynamicLabel.h"

#import <UIKit/UIKit.h>
#import "SimpleAudioEngine.h"

#define BACKGROUND_PIXEL        RGB565
#define DIALOG_CONTENT_PIXEL    RGBA4444

typedef void (^SceneBlock)();

typedef struct CGPoint CLPeriod; //x = start time , y = end time

@interface DialogContentLayer : CCLayer <CDLongAudioSourceDelegate>
{
    NSUInteger          _numberOfScenes;
    NSUInteger          _indexOfCurrentScene;
    CGRect              _dialogBoxRect;
    
    SceneBlock          *sceneBlocks;
    
    CDLongAudioSource   *_audioSource;
    NSTimeInterval      audioPauseTime;
    CLPeriod            *scenePeriods;
    NSMutableArray      * firstAnimIdxOfScene;
    NSMutableArray      *   animStartTime; // start time for each animation
    NSMutableArray      *   animSpritesNames;
    NSMutableArray      *   animSprites;// store all sprites with animation
    // use this index to retrieve the starting time of the animation.  Inside update function, whenever the current audio time is greater than the startingTime, the animation will start.
    NSMutableDictionary *   animName2SpriteIdx;  // some animated
    
    // used for audio sync text
    
    CCLabelBMFont       * foregroundLabel;
    CCLabelBMFont       * whiteboardBackgroundLabel;
    int                   currWordOnWhiteBoardIdx;
    NSArray             * wordsAudioPos;
    
    
    
}

// weak ref to toolbar of dialog scene
@property (nonatomic,unsafe_unretained,readonly) ToolbarLayer *toolbar;

@property (nonatomic,assign,readonly) NSUInteger numberOfScenes;
@property (nonatomic,assign,readonly) NSUInteger indexOfCurrentScene;
@property (nonatomic,assign,readonly) CGRect     dialogBoxRect;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) NSString * lessonLetter;
@property (nonatomic,assign) NSString * soundNameWord;
//@property (nonatomic,assign) NSString * letterSoundInWord;

// key: sceneIdx  value: array of positions in the audio file of words from dialog
@property (nonatomic,assign) NSMutableDictionary *soundLabelDict;
@property (nonatomic,assign) NSMutableDictionary *animStartTimeDict;

@property (nonatomic,assign) NSMutableDictionary *dialogDict;
- (void) clearScene;
- (id) init;
- (id) initWithInitOptions:(NSDictionary*)options;
- (void) showWhiteBoardWordsSyncWithAudio;
- (void) dialogPlayEnd;
- (void) initScene:(int) sceneIdx;
- (void) resetScene;
// flags
- (BOOL) isAtFirstScene;
- (BOOL) isAtLastScene;
- (CCAnimation*) loadPlistForAnimationWithName:(NSString*)plistFileName frameName:(NSString*)fName startFrameIdx:(int)startIdx endFrameIndx:(int)endIdx;
#pragma mark --DialogControl

- (void) dialogPlay;
- (void) dialogPause;
- (void) dialogResume;
- (void) dialogStop;

- (BOOL) playSceneWithIndex:(NSUInteger)index;

- (void) dialogPlayNextScene;
- (void) dialogPlayPreviousScene;
- (void) dialogReplayCurrentScene;

#pragma mark --Dialog audio control

- (void) dialogAudioPlayDoneWithIndex:(NSUInteger)index;

@end
