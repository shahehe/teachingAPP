//
//  TouchGameLayer.m
//  touchGames
//
//  Created by yiplee on 14-3-13.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "TouchGameLayer.h"

#import "config.h"

@implementation GameObject

+ (GameObject*) objectWithFile:(NSString *)file content:(NSString *)content audioFileName:(NSString *)audio
{
    return [[[self alloc] initWithFile:file content:content audioFileName:audio] autorelease];
}

- (id) initWithFile:(NSString *)file content:(NSString *)content audioFileName:(NSString *)audio
{
    self = [super initWithFile:file];
    NSAssert(self, @"Game object failed init");
    
    self.name = nil;
    self.content = content;
    self.audioFileName = audio;
    
    _touchRect.origin = CGPointZero;
    _touchRect.size = self.boundingBox.size;
    _block = nil;
    

    return self;
}

- (void) onEnter
{
    [super onEnter];
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void) onExitTransitionDidStart
{
    [super onExitTransitionDidStart];
//    CCLOG(@"remove touch delegate");
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

- (void) dealloc
{
    [_name release];
    [_content release];
    [_audioFileName release];
    
    [_block release];
    _block = nil;
    
    [super dealloc];
}

- (void) setBlock:(void (^)(id))block
{
    [_block release];
    _block = [block copy];
}

#pragma mark --touch

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pos = [self convertTouchToNodeSpace:touch];
//    CGRect rect = CGRectZero;
//    rect.size = self.boundingBox.size;
    
    if (CGRectContainsPoint(_touchRect, pos))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pos = [self convertTouchToNodeSpace:touch];
//    CGRect rect = CGRectZero;
//    rect.size = self.boundingBox.size;
    
    if (CGRectContainsPoint(_touchRect, pos) && _block)
    {
        _block(self);
    }

}

@end

/***********************************************************
 * file -> sprite then add sprite to node
 * retuen sprite
 */

CCSprite* addFileToNodeAsSprite(NSString *file,CCNode *parent)
{
    CCSprite *s = [CCSprite spriteWithFile:file];
    [parent addChild:s];
    
    return s;
}

/*
 * the position of the right upper point of screen.
 */

CGPoint screenSizeAsPoint()
{
    CGSize s = [[CCDirector sharedDirector] winSize];
    return ccpFromSize(s);
}

#define BLINK_ACTION_TAG 42

@implementation TouchGameLayer
{
    CDLongAudioSource *audioPlayer; //strong
    
    DLSubtitleLabel *contentLabel; // weak
    
    // search path for images & audio
    NSString *searchPath;
}

+ (TouchGameLayer *) gameLayerWithGameData:(NSDictionary *)dic
{
    return [[[self alloc] initWithGameData:dic] autorelease];
}

- (id) initWithGameData:(NSDictionary *)dic
{
    self = [super init];
    NSAssert(self, @"TouchGameLayer failed init");
    
    searchPath = [[dic objectForKey:@"path"] copy];
//    CCLOG(@"path:%@",searchPath);
    [self setSearchPath];
    
    // background z:0
    NSString *background = [dic objectForKey:@"background"];
    CCSprite *bg = addFileToNodeAsSprite(background, self);
    bg.zOrder = 0;
    bg.position = ccpMult(screenSizeAsPoint(), 0.5);

    NSDictionary *objectsData = [dic objectForKey:@"objects"];
    [self loadObjectsWithData:objectsData];
    
    //audio
    audioPlayer = [[CDLongAudioSource alloc] init];
    audioPlayer.delegate = self;
    
    // contentLabel
    NSDictionary *labelData = [dic objectForKey:@"label"];
    [self addContentLabelWithData:labelData];
    
    // Menu
    CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"MENU" block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[TouchingGameMenu scene]];
    }];
    back.color = ccBLACK;
    back.position = ccpCompMult(screenSizeAsPoint(), ccp(0.1,0.95));
    
    CCMenuItemFont *restart = [CCMenuItemFont itemWithString:@"RESTART" block:^(id sender) {
        TouchGameLayer *game = [TouchGameLayer gameLayerWithGameData:dic];
        CCScene *scene = [CCScene node];
        [scene addChild:game];
        [[CCDirector sharedDirector] replaceScene:scene];
    }];
    restart.color = ccBLACK;
    restart.position = ccpCompMult(screenSizeAsPoint(), ccp(0.9,0.95));
    
    CCMenu *menu = [CCMenu menuWithItems:back,restart, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    [audioPlayer release];
    audioPlayer= nil;
    
    [searchPath release];
    searchPath = nil;
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    [self setSearchPath];
}

- (void) onExit
{
    [super onExit];
    [self resetSearchPath];
}

- (void) setSearchPath
{
    CCFileUtils *util = [CCFileUtils sharedFileUtils];
    
    NSMutableArray *paths = [util.searchPath mutableCopy];
    
    if (![[paths firstObject] isEqualToString:searchPath])
        [paths insertObject:searchPath atIndex:0];
    
    util.searchPath = paths;
    [paths release];
    
//    CCLOG(@"set path:%@",util.searchPath.description);
}

- (void) resetSearchPath
{
    CCFileUtils *util = [CCFileUtils sharedFileUtils];
    
    NSMutableArray *paths = [util.searchPath mutableCopy];
    
//    for (;[paths containsObject:searchPath];)
//    {
        [paths removeObject:searchPath];
//    }
    
    util.searchPath = paths;
    [paths release];
    
//    CCLOG(@"reset path:%@",util.searchPath.description);
}

- (void) addContentLabelWithData:(NSDictionary *)data
{
    NSString *fontFile = [data objectForKey:@"fntFile"];
    CGPoint pos = CGPointFromString([data objectForKey:@"position"]);
//    NSString *content = [data objectForKey:@"content"];
    
    NSString *fntFilePath = [[NSString stringWithUTF8String:BMFontDirPath] stringByAppendingPathComponent:fontFile];
    
    contentLabel = [DLSubtitleLabel labelWithString:@"" fntFile:fntFilePath];
    contentLabel.position = ccpCompMult(screenSizeAsPoint(), pos);
    contentLabel.anchorPoint = ccp(0,0.5);
    contentLabel.delegate = self;
    
    [self addChild:contentLabel z:2];
    
    contentLabel.touchEnable = YES;
}

- (void) loadObjectsWithData:(NSDictionary *)data
{
    for (NSString *name in data.allKeys)
    {
        NSDictionary *objectData = [data objectForKey:name];
        [self addObjectWithData:objectData name:name];
    }
}

- (void) addObjectWithData:(NSDictionary*)data name:(NSString*)name
{
    NSString *file = [data objectForKey:@"file"];
    NSString *audio = [data objectForKey:@"audio"];
    NSString *content = [data objectForKey:@"content"];
    GameObject *object = [GameObject objectWithFile:file content:content audioFileName:audio];
    
    object.name = name;
    CGPoint pos = CGPointFromString([data objectForKey:@"position"]);
    object.position = ccpCompMult(screenSizeAsPoint(), pos);
    [self addChild:object];
    object.zOrder = 1;
    
    __block id self_copy = self;
    [object setBlock:^(id sender) {
        [self_copy objectHasBeenClicked:sender];
    }];
    
    //blink
    CCFadeTo *fade_out = [CCFadeTo actionWithDuration:0.8 opacity:255/2.5];
    CCFadeTo *fade_in = [CCFadeTo actionWithDuration:0.8 opacity:255];
    CCSequence *s = [CCSequence actions:fade_out,fade_in, nil];
    CCRepeatForever *r = [CCRepeatForever actionWithAction:s];
    r.tag = BLINK_ACTION_TAG;
    [object runAction:r];
}

- (void) objectHasBeenClicked:(GameObject *)object
{
    CCAction *action = [object getActionByTag:BLINK_ACTION_TAG];
    if (action)
    {
        [object stopAction:action];
        object.opacity = 255;
    }
    
    contentLabel.string = object.content;
    
    [audioPlayer stop];
    [audioPlayer load:object.audioFileName];
    [audioPlayer rewind];
    [audioPlayer play];
}

#pragma mark --CDLongAudioSourceDelegate

- (void) cdAudioSourceDidFinishPlaying:(CDLongAudioSource *)audioSource
{
    [audioPlayer stop];
}

#pragma mark --DLSubtitleLabelDelegate

- (void) subtitleLabelClickOnWord:(NSString *)word sender:(id)sender
{
    CCLOG(@"touch at word:%@",word);
}

@end
