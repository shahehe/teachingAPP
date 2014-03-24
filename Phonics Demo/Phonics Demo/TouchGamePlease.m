//
//  TouchGamePlease.m
//  LetterE
//
//  Created by yiplee on 14-3-20.
//  Copyright (c) 2014年 USTB. All rights reserved.
//
static char *const file = "please.plist";

#import "config.h"
#import "TouchGamePlease.h"

#define __startPosition CCMP(0.645,0.926)
#define __endPosition   CCMP(0.645,0.531)
#define __finalPositionX (SCREEN_WIDTH * 0.121)

#define GIRL_1 @"girl_1.png"
#define GIRL_2 @"girl_2.png"

@interface TouchGamePlease ()
{
    CCSprite *girl;
    
    CGPoint startPos;
    CGPoint endPos;
    
    CCArray *selectedObjects;
}

@end

@implementation TouchGamePlease
{
    int __count;
}

+ (TouchGamePlease *) gameLayer
{
    NSString *rootPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:touchingGameRootPath]];
    NSString *fileName = [NSString stringWithUTF8String:file];
    NSString *filePath = [rootPath stringByAppendingPathComponent:fileName];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return [[[self alloc] initWithGameData:dic] autorelease];
}

- (id) initWithGameData:(NSDictionary *)dic
{
    self = [super initWithGameData:dic];
    NSAssert(self, @"game:I see failed init");
    
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [[CCTextureCache sharedTextureCache] addImageAsync:GIRL_1 withBlock:^(CCTexture2D *tex) {
        CGRect rect = CGRectZero;
        rect.size = tex.contentSize;
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
        [frameCache addSpriteFrame:frame name:GIRL_1];
        
        girl = [CCSprite spriteWithSpriteFrame:frame];
        girl.zOrder = 0;
        [self addChild:girl];
        [self resetGirl];
    }];
    [[CCTextureCache sharedTextureCache] addImageAsync:GIRL_2 withBlock:^(CCTexture2D *tex) {
        CGRect rect = CGRectZero;
        rect.size = tex.contentSize;
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
        [frameCache addSpriteFrame:frame name:GIRL_2];
    }];
    
    __block id self_copy = self;
    [self setObjectActivedBlock:^(GameObject *object) {
        blinkSprite(object);
        
        CCMoveTo *move = [CCMoveTo actionWithDuration:1 position:__startPosition];
        CCCallBlock *block = [CCCallBlock actionWithBlock:^{
            [self_copy resetGirl];
        }];
        CCSequence *seq = [CCSequence actions:move,block, nil];
        [object runAction:seq];
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        unblinkSprite(object);
    }];
    
    selectedObjects = [[CCArray alloc] init];
    self.autoActiveNext = NO;
    
    return self;
}

- (void) dealloc
{
    [selectedObjects release];
    [super dealloc];
}

- (void) setGameMode:(TouchGameMode)gameMode
{
    // do nothing
}

- (void) setGirl
{
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:GIRL_2];
    girl.displayFrame = frame;
    girl.position = CCMP(0.618, 0.508);
}

- (void) resetGirl
{
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:GIRL_1];
    girl.displayFrame = frame;
    girl.position = CCMP(0.582, 0.512);
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;
    
    if (![selectedObjects containsObject:object])
    {
        [object stopAllActions];
        object.position = __startPosition;
    }
    return YES;
}

- (void) contentDidFinishReading:(GameObject *)object
{
    [super contentDidFinishReading:object];
    
    if ([selectedObjects containsObject:object])
        return;
    
    [self setGirl];
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.8 position:__endPosition];
    CCEaseIn *ease = [CCEaseIn actionWithAction:move rate:1];
    
    __block id self_copy = self;
    CCDelayTime *delay = [CCDelayTime actionWithDuration:1];
    CCCallBlock *block = [CCCallBlock actionWithBlock:^{
        [self_copy placeObject:object];
        [self_copy activeNextObjects];
    }];
    
    CCSequence *seq = [CCSequence actions:ease,delay,block, nil];
    [object runAction:seq];
    
    [selectedObjects addObject:object];
}

- (void) placeObject:(GameObject*)object
{
    CGFloat height = SCREEN_HEIGHT / self.objectCount;
    CGPoint pos = ccp(__finalPositionX, height*(0.5+__count));
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.5 position:pos];
    [object runAction:move];
    __count++;
}

@end
