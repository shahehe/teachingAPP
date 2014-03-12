//
//  PhonicsGames.m
//  little games
//
//  Created by yiplee on 14-2-19.
//  Copyright (c) 2014年 yiplee. All rights reserved.
//

#import "PhonicsGames.h"

// Games
#import "PhonicsGameLayer.h"

@implementation PhonicsGames
{
    NSUInteger _sceneLevel;
    
    /*
     标记是否有游戏正在运行
     */
    BOOL _isGameRunning;
}

+ (PhonicsGames *) sharedGames
{
    static PhonicsGames *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id) init
{
    if ( self = [super init])
    {
        _sceneLevel = [[CCDirector sharedDirector]currentSceneStackLevel];
        _isGameRunning = NO;
    }
    return self;
}

- (void) phonicsGameExit:(id)sender
{
    NSAssert(_isGameRunning, @"there is no game running but receive a msg that a game wants to exit");
    
    //***********************************
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    [sharedFileUtils setEnableFallbackSuffixes:YES];
    [sharedFileUtils setiPadSuffix:@"-ipad"];
    [sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];
    //***********************************
    
    [[CCDirector sharedDirector] popToSceneStackLevel:_sceneLevel];
    _isGameRunning = NO;
    
    [[NSNotificationCenter defaultCenter] \
     removeObserver:self name:@"PhonicsGameExit" object:nil];
}

- (void) startGame:(PhonicsGameName)gameName data:(NSDictionary *)gameData
{
    NSAssert(!_isGameRunning, @"can't launch multiple games");
    NSString *gameNameString \
    = [NSString stringWithUTF8String:gameNames[gameName]];
    
    Class game = NSClassFromString(gameNameString);
    
    NSAssert([game isSubclassOfClass:[PhonicsGameLayer class]], @"invalid game, can't launch");
    
    //***********************************
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    [sharedFileUtils setEnableFallbackSuffixes:YES];
    [sharedFileUtils setiPadSuffix:@""];
    [sharedFileUtils setiPadRetinaDisplaySuffix:@"-hd"];
    //***********************************
    
    CCScene *scene =
    [game performSelector:@selector(gameWithData:) withObject:gameData];
    
    [[NSNotificationCenter defaultCenter] \
     addObserver:self
     selector:@selector(phonicsGameExit:)
     name:@"PhonicsGameExit"
     object:nil];
    
    _sceneLevel = [[CCDirector sharedDirector] currentSceneStackLevel];
    _isGameRunning = YES;
    [[CCDirector sharedDirector] pushScene:scene];
}

@end
