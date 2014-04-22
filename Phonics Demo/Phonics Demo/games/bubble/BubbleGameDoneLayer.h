//
//  GameDoneLayer.h
//  bubble
//
//  Created by yiplee on 13-4-27.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BubbleGameDoneLayer : CCLayer

@property (nonatomic,assign) NSUInteger score;
@property (nonatomic,assign) NSUInteger coin;
@property (nonatomic,assign) NSUInteger starLevel;

+ (CCScene*) sceneWithBackScene:(CCScene*)scene;
- (id) initWithBackScene:(CCScene*)scene;

@end
