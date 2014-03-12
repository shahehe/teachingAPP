//
//  PhonicsGames.h
//  little games
//
//  Created by yiplee on 14-2-19.
//  Copyright (c) 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

typedef NS_ENUM(NSUInteger, PhonicsGameName)
{
    PhonicsGameLearnWord    = 0,
    PhonicsGameSearchWord   = 1,
    PhonicsGameCardMatching = 2,
    PhonicsGameBubbleGame   = 3,
    PhonicsGameLetterWriting = 4,
    PhonicsGameLetterSound = 5,
    // other games
    
    PhonicsGameMaxIndex,
};

static char *const gameNames[] = {"LearnWord",
    "SearchWord",
    "CardMatching",
    "BubbleGameLayer",
    "LetterWriting",
    "LetterSound",
};

@interface PhonicsGames : NSObject

+ (PhonicsGames *) sharedGames;

- (void) startGame:(PhonicsGameName)gameName data:(NSDictionary*)gameData;

@end
