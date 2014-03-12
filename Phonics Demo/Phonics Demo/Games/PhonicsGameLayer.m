//
//  PhonicsGameLayer.m
//  little games
//
//  Created by yiplee on 14-2-19.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "PhonicsGameLayer.h"

@implementation PhonicsGameLayer

@synthesize gameData = _gameData;

+ (CCScene *) gameWithData:(NSDictionary *)data
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [[[[self class] alloc] initWithGameData:data] \
                      autorelease];
    [scene addChild:layer];
    return scene;
}

- (id) initWithGameData:(NSDictionary *)data
{
    if (self = [super init])
    {
        self.gameData = data;
    }
    return self;
}

- (void) dealloc
{
    [_gameData release];
    _gameData = nil;
    
    [super dealloc];
}

@end
