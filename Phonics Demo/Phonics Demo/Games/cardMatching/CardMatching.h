//
//  CardMatching.h
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "CardMatchingGamePrepareLayer.h"
#import "CardMatchingGameLayer.h"
#import "CardMatchingLevelDoneLayer.h"
#import "CardMatchingGameDoneLayer.h"
#import "CardMatchingGameOverLayer.h"

#import "PhonicsGameLayer.h"

typedef enum
{
    GamePrepareLayer = 0,
    GameLayer,
    LevelDoneLayer,
    GameDoneLayer,
    GameOverLayer
}GameLayerTag;

@interface CardMatching : PhonicsGameLayer
{
    CCLayerMultiplex *mpLayer;  //weak ref
    
    CardMatchingGameLayer *gameLayer;   //weak ref
    CardMatchingGamePrepareLayer *gamePrepareLayer;
    CardMatchingLevelDoneLayer *levelDoneLayer;  
    CardMatchingGameDoneLayer *gameDoneLayer;
    CardMatchingGameOverLayer *gameOverLayer;
}

+ (CCScene*) scene;

- (void) gameStart;

- (void) levelDone;

- (void) nextLevel;

- (void) playAgain;

- (void) gameOver;

- (void) gameDone;

- (void) backToMainMenu;

@end
