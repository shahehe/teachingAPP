//
//  PGLearnWord.h
//  Phonics Games
//
//  Created by yiplee on 14-4-1.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "SimpleAudioEngine.h"

typedef enum : NSUInteger {
    LearnWordLevelEasy = 1,
    LearnWordLevelNormal,
    LearnWordLevelHard
} LearnWordLevel;

@interface PGLearnWord : CCLayer<CDLongAudioSourceDelegate>

@property (nonatomic,copy,readonly) NSString *gameName;
@property (nonatomic,retain) NSArray *words;
@property (nonatomic,copy,readonly) NSString *currentWord;

@property (nonatomic,assign) LearnWordLevel gameLevel;

+ (instancetype) gameWithWords:(NSArray*)words;
- (id) initWithWords:(NSArray*)words;

@end
