//
//  GameLayer.h
//  bubble
//
//  Created by yiplee on 13-4-2.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum : NSUInteger {
    BubbleLevelEasy = 1,
    BubbleLevelNormal,
    BubbleLevelHard
} BubbleLevel;

@interface BubbleGameLayer : CCLayer

+ (CCScene*) gameWithWords:(NSArray*)words;

- (id) initWithWords:(NSArray*)words;

@property (nonatomic,copy,readonly) NSString *gameName;
@property (nonatomic,assign) BubbleLevel gameLevel;

- (void) backToMenu;

// cache
+ (void) preloadTextures;
+ (void) cleanCaches;

@end
