//
//  CardMatching.h
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CardMatchingGameLayer.h"
#import "CardMatchingLevelDoneLayer.h"
#import "CardMatchingGameDoneLayer.h"
#import "CardMatchingGameOverLayer.h"
#import "CardMatchPauseMenu.h"
#import "Button.h"

typedef enum
{
    GameLayer = 0,
    LevelDoneLayer,
    GameDoneLayer,
    GameOverLayer
}GameLayerTag;

@interface CardMatching : CCLayer
{
    CCLayerMultiplex *mpLayer;  //weak ref
    
    CardMatchingGameLayer *gameLayer;   //weak ref
    CardMatchingLevelDoneLayer *levelDoneLayer;  
    CardMatchingGameDoneLayer *gameDoneLayer;
    CardMatchingGameOverLayer *gameOverLayer;
}

@property (nonatomic,copy,readonly) NSString *gameName;

+ (CCScene*) gameWithWords:(NSArray*)words;

- (void) pause;

- (void) levelDone;

- (void) nextLevel;

- (void) playAgain;

- (void) retry;

- (void) gameOver;

- (void) gameDone;

- (void) backToMainMenu;

@end
