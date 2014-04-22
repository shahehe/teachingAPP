//
//  TouchGameLayer.m
//  touchGames
//
//  Created by yiplee on 14-3-13.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "TouchGameLayer.h"

#import "config.h"

@interface GameObject ()
{
    void (^_block)(id sender);
}

- (void) setBlock:(void (^)(id sender))block;

@end

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
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
}

- (void) onExitTransitionDidStart
{
    [super onExitTransitionDidStart];
//    CCLOG(@"remove touch delegate");
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

- (void) dealloc
{
    CCLOG(@"game object:%@ dealloc",self.name);
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
    
    if (CGRectContainsPoint(_touchRect, pos) && self.visible)
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

#define BLINK_ACTION_TAG -102

void blinkSprite(CCSprite *t)
{
    unblinkSprite(t);
    
    CCFadeTo *fade_out = [CCFadeTo actionWithDuration:0.8 opacity:255/2.5];
    CCFadeTo *fade_in = [CCFadeTo actionWithDuration:0.8 opacity:255];
    CCSequence *s = [CCSequence actions:fade_out,fade_in, nil];
    CCRepeatForever *r = [CCRepeatForever actionWithAction:s];
    r.tag = BLINK_ACTION_TAG;
    [t runAction:r];
}

void unblinkSprite(CCSprite *t)
{
    CCAction *action = [t getActionByTag:BLINK_ACTION_TAG];
    if (action)
    {
        [t stopAction:action];
        t.opacity = 255;
    }
}

@implementation TouchGameLayer
{
    CDLongAudioSource *audioPlayer; //strong
    
    DLSubtitleLabel *contentLabel; // weak
    
    // search path for images & audio
    NSString *searchPath;
    
    NSMutableArray *objects;
    
    GameObject *_runningObject;
}

@synthesize runningObject = _runningObject;
@synthesize autoActiveNext = _autoActiveNext;

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
    
    // title
    _gameTitle = [[dic objectForKey:@"title"] copy];
    // background z:0
    NSString *background = [dic objectForKey:@"background"];
    CCSprite *bg = addFileToNodeAsSprite(background, self);
    bg.zOrder = 0;
    bg.position = ccpMult(screenSizeAsPoint(), 0.5);
    bg.scaleX = SCREEN_WIDTH/bg.contentSize.width;
    bg.scaleY = SCREEN_HEIGHT/bg.contentSize.height;

    NSDictionary *objectsData = [dic objectForKey:@"objects"];
    objects = [[NSMutableArray alloc] initWithCapacity:objectsData.count];
    [self loadObjectsWithData:objectsData];
    
    NSDictionary *staticObjectsData = [dic objectForKey:@"staticObjects"];
    if (staticObjectsData)
    {
        [self loadStaticObjectsWithData:staticObjectsData];
    }
    //audio
    audioPlayer = [[CDLongAudioSource alloc] init];
    audioPlayer.delegate = self;
    
    // contentLabel
    NSDictionary *labelData = [dic objectForKey:@"label"];
    [self addContentLabelWithData:labelData];
    
    // Menu
    __block id self_copy = self;
    CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"MENU" block:^(id sender) {
        [self_copy cleanCache];
        [[CCDirector sharedDirector] popScene];
    }];
    back.color = ccBLACK;
    back.position = ccpCompMult(screenSizeAsPoint(), ccp(0.1,0.95));
    
    CCMenuItemFont *restart = [CCMenuItemFont itemWithString:@"RESTART" block:^(id sender) {
        TouchGameLayer *game = [[self class] gameLayerWithGameData:dic];
        CCScene *scene = [CCScene node];
        [scene addChild:game];
        [[CCDirector sharedDirector] replaceScene:scene];
    }];
    restart.color = ccBLACK;
    restart.position = ccpCompMult(screenSizeAsPoint(), ccp(0.9,0.95));
    
    CCMenu *menu = [CCMenu menuWithItems:back,restart, nil];
    menu.zOrder = 10;
    menu.position = CGPointZero;
    [self addChild:menu];
    
    //block
    [self setObjectCLickedBlock:^(GameObject *object) {
        unblinkSprite(object);
    }];
    [self setObjectActivedBlock:^(GameObject *object) {
        blinkSprite(object);
    }];
    
    _objectLoaded = nil;
    
    // gameMode
    _gameMode = GameModeDefault;
    
    _runningObject = nil;
    
    _autoActiveNext = YES;
    
    return self;
}

- (void) dealloc
{
    CCLOG(@"touch game:%@ dealloc",self.gameTitle);
    
    [_gameTitle release];
    
    [objects release];
    objects = nil;
    
    [contentLabel release];
    contentLabel = nil;
    
    [audioPlayer release];
    audioPlayer= nil;
    
    [searchPath release];
    searchPath = nil;
    
    [_objectClicked release];
    [_objectLoaded release];
    [_objectActived release];
    
    [super dealloc];
}

- (void) onEnter
{
    [super onEnter];
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    [self setSearchPath];
    
    BOOL isActive = NO;
    for (GameObject *object in objects)
    {
        if (object.tag == 1)
        {
            isActive = YES;
            break;
        }
    }
    
    if (!isActive)
    {
        for (GameObject *object in objects)
        {
            if (_objectLoaded)
                _objectLoaded(object);
        }
        [self activeNextObjects];
    }
}

- (void) onExit
{
    [super onExit];
    [self resetSearchPath];
}

- (void) cleanCache
{
    for (CCNode *child in self.children)
    {
        if ([child isKindOfClass:[CCSprite class]])
        {
            CCTexture2D *tex = ((CCSprite*)child).displayFrame.texture;
            CCLOG(@"releae tex:%@",tex.description);
            [[CCTextureCache sharedTextureCache] removeTexture:tex];
        }
    }
    
    [[CCFileUtils sharedFileUtils] purgeCachedEntries];
}

- (NSUInteger) objectCount
{
    return [objects count];
}

- (GameObject *) gameObjectAtIndex:(NSInteger)idx
{
    if (idx < 0 || idx >= objects.count)
        return nil;
    
    return [objects objectAtIndex:idx];
}

- (DLSubtitleLabel*) contentLabel
{
    return contentLabel;
}

- (void) setObjectLoadedBlock:(void (^)(GameObject *))block
{
    [_objectLoaded release];
    _objectLoaded = [block copy];
}

- (void) setObjectActivedBlock:(void (^)(GameObject *))block
{
    [_objectActived release];
    _objectActived = [block copy];
}

- (void) setObjectCLickedBlock:(void (^)(GameObject *))block
{
    [_objectClicked release];
    _objectClicked = [block copy];
}

- (NSArray *) nextObjects
{
    NSMutableArray *array = [NSMutableArray array];
    for (GameObject *object in objects)
    {
        if (object.tag == 0)
        {
            [array addObject:object];
            if (_gameMode == GameModeOneByOne)
                break;
        }
    }
    return array;
}

- (void) activeNextObjects
{
    for (GameObject *object in [self nextObjects])
    {
        if (_objectActived)
        {
            _objectActived(object);
            
        }
        object.tag = 1;
        _runningObject = object;
//        [audioPlayer load:object.audioFileName];
    }
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
    CGPoint anchor = CGPointFromString([data objectForKey:@"anchorPoint"]);
    NSString *fntFilePath = [[NSString stringWithUTF8String:BMFontDirPath] stringByAppendingPathComponent:fontFile];
    
    contentLabel = [DLSubtitleLabel labelWithString:@"" fntFile:fntFilePath];
    contentLabel.position = ccpCompMult(screenSizeAsPoint(), pos);
    contentLabel.anchorPoint = anchor;
    contentLabel.delegate = self;
    
    contentLabel.color = ccBLACK;
    contentLabel.highlightedColor = ccGREEN;
    
    [self addChild:contentLabel z:2];
    
    contentLabel.touchEnable = YES;
}

- (void) loadStaticObjectsWithData:(NSDictionary *)data
{
    for (NSString *name in data.allKeys)
    {
        CGPoint pos = CGPointFromString([data objectForKey:name]);
        CCSprite *s = [CCSprite spriteWithFile:name];
        s.position = ccpCompMult(SCREEN_SIZE_AS_POINT, pos);
        s.zOrder = 1;
        [self addChild:s];
    }

}

- (void) loadObjectsWithData:(NSDictionary *)data
{
    for (NSString *name in [data.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)])
    {
        NSString *realName = [[name componentsSeparatedByString:@"-"] lastObject];
        NSDictionary *objectData = [data objectForKey:name];
        [self addObjectWithData:objectData name:realName];
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
    
    object.tag = 0;
    [objects addObject:object];
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if (object.tag == 0) return NO;
    
    _runningObject = object;
    if (_objectClicked)
    {
        _objectClicked(object);
    }
    
    contentLabel.string = object.content;
    [contentLabel highlightFirstLetterOfWord:object.name color:contentLabel.highlightedColor];
    [audioPlayer stop];
    
    if (object.audioFileName)
    {
        [audioPlayer load:object.audioFileName];
        [audioPlayer rewind];
        [audioPlayer play];
    }
    
    if (object.tag == 1 && _autoActiveNext)
    {
        [self activeNextObjects];
    }
    
    object.tag = MAX(object.tag, 2);
    
    return YES;
}

- (void) contentDidFinishReading:(GameObject *)object
{
    // override me
}

#pragma mark --CDLongAudioSourceDelegate

- (void) cdAudioSourceDidFinishPlaying:(CDLongAudioSource *)audioSource
{
    [audioPlayer stop];
    [self contentDidFinishReading:_runningObject];
}

#pragma mark --DLSubtitleLabelDelegate

- (void) subtitleLabelClickOnWord:(NSString *)word sender:(id)sender
{
    CCLOG(@"touch at word:%@",word);
    [audioPlayer rewind];
    [audioPlayer play];
}

@end
