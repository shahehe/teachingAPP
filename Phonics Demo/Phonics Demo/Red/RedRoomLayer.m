//
//  MyCocos2DClass.m
//  LetterE
//
//  Created by yiplee on 14-3-12.
//  Copyright 2014年 USTB. All rights reserved.
//

#import "RedRoomLayer.h"
#import "PhonicsDefines.h"
#import "SimpleAudioEngine.h"

#import "MainMenu.h"

#define BLINK_ACTION_TAG 10

@implementation RedRoomLayer
{
    NSDictionary *objectData;
    CCArray *names;
    CCArray *objects;
    
    DLSubtitleLabel *content;
}

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [RedRoomLayer node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    self = [super init];
    NSAssert(self, @"RedRoomLayer init failed");
    
    CCSprite *background = [CCSprite spriteWithFile:@"red_background.png"];
    background.position = CMP(0.5);
    [self addChild:background z:0];
    
    objectData = @{@"rug": @{@"normal": @"rug.png",
                                 @"selected":@"red_rug.png",
                                 @"position":@"{0.675,0.196}",
                                 @"audio":@"rug.mp3"},
                   @"rooster": @{@"normal": @"rooster.png",
                                 @"selected":@"red_rooster.png",
                                 @"position":@"{0.395,0.661}",
                                 @"audio":@"rooster.mp3"},
                   @"ring":    @{@"normal": @"ring.png",
                                @"selected":@"red_ring.png",
                                @"position":@"{0.754,0.468}",
                                @"audio":@"ring.mp3"},
                   @"road":    @{@"normal": @"road.png",
                                @"selected":@"red_road.png",
                                @"position":@"{0.130,0.772}",
                                @"audio":@"road.mp3"},
                   @"rose":   @{@"normal": @"rose.png",
                                @"selected":@"red_rose.png",
                                @"position":@"{0.142,0.199}",
                                @"audio":@"rose.mp3"},
                   @"rocket": @{@"normal": @"rocket.png",
                                @"selected":@"red_rocket.png",
                                @"position":@"{0.868,0.822}",
                                @"audio":@"rocket.mp3"}};
    [objectData retain];
    
    NSUInteger tag = 0;
    names = [[CCArray arrayWithCapacity:objectData.count] retain];
    objects = [[CCArray arrayWithCapacity:objectData.count] retain];
    
    for (NSString *name in [objectData allKeys])
    {
        NSDictionary *info = [objectData objectForKey:name];
        NSString *normal = [info objectForKey:@"normal"];
        NSString *selected = [info objectForKey:@"selected"];
        CGPoint pos = ccpCompMult(SCREEN_SIZE_AS_POINT, CGPointFromString([info objectForKey:@"position"]));
        NSString *audio = [info objectForKey:@"audio"];
        [[CCTextureCache sharedTextureCache] addImage:normal];
        [[CCTextureCache sharedTextureCache] addImage:selected];
        
        CCSprite *object = [CCSprite spriteWithFile:normal];
        object.position = pos;
        object.tag = tag++;
        [self addChild:object z:1];
        [names addObject:name];
        [objects addObject:object];
        [[SimpleAudioEngine sharedEngine] preloadEffect:audio];
        
        //blink
        CCFadeTo *fade_out = [CCFadeTo actionWithDuration:0.8 opacity:255/3];
        CCFadeTo *fade_in = [CCFadeTo actionWithDuration:0.8 opacity:255];
        CCSequence *s = [CCSequence actions:fade_out,fade_in, nil];
        CCRepeatForever *r = [CCRepeatForever actionWithAction:s];
        r.tag = BLINK_ACTION_TAG;
        [object runAction:r];
    }
    
    content = [DLSubtitleLabel labelWithString:@" " fntFile:@"Didot.fnt"];
    content.anchorPoint = ccp(0, 0.5);
    content.position = CCMP(0.3, 0.06);
    [self addChild:content];
    
    content.delegate = self;
    content.touchEnable = YES;
    
    [self setTouchEnabled:YES];
    
    return self;
}

- (void) onExit
{
    [super onExit];
    
    for (NSString *name in names)
    {
        NSDictionary *info = [objectData objectForKey:name];
        NSString *audio = [info objectForKey:@"audio"];
        
        [[SimpleAudioEngine sharedEngine] unloadEffect:audio];
    }
}

- (void) dealloc
{
    [objectData release];
    [names release];
    [objects release];
    
    [super dealloc];
}

- (void) activeObject:(CCSprite *)object
{
    NSAssert([objects containsObject:object], @"object is invalid");
    
    [object stopActionByTag:BLINK_ACTION_TAG];
    object.opacity = 255;
    
    NSUInteger tag = object.tag;
    NSString *name = [names objectAtIndex:tag];
    
    NSDictionary *info = [objectData objectForKey:name];
    NSString *selected = [info objectForKey:@"selected"];
    
    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] textureForKey:selected];
    CGRect rect = CGRectZero;
    rect.size = tex.contentSize;
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
    object.displayFrame = frame;
    
    NSString *audio = [info objectForKey:@"audio"];
    [[SimpleAudioEngine sharedEngine] playEffect:audio];
    
    [content setString:[NSString stringWithFormat:@"Here is a red %@.",name]];
}

#pragma mark --touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
//    CGPoint pos = [self convertTouchToNodeSpace:touch];
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pos = [self convertTouchToNodeSpace:touch];

    for (CCSprite *object in objects)
    {
        if (CGRectContainsPoint(object.boundingBox, pos))
        {
            [self activeObject:object];
            break;
        }
    }
}

- (void) subtitleLabelClickOnWord:(NSString *)word sender:(id)sender
{
    CCLOG(@"click on %@",word);
    
    //临时
    if ([word isEqualToString:@"Here"])
    {
        [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
    }
}

@end
