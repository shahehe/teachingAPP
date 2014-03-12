//
//  Gardenlayer.m
//  garden
//
//  Created by yiplee on 14-3-10.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "Gardenlayer.h"
#import "SimpleAudioEngine.h"

@interface GardenObject : DLDraggableSprite
{
    NSString *_name;
    NSString *_audioFile;
}

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *audioFile;

+ (GardenObject *) objectWithFile:(NSString*)file name:(NSString*)name audioFile:(NSString*)audioFile;
- (id) initWithFile:(NSString*)file name:(NSString*)name audioFile:(NSString*)audioFile;

@end

@implementation GardenObject

@synthesize name = _name,audioFile = _audioFile;

+ (GardenObject *) objectWithFile:(NSString *)file name:(NSString *)name audioFile:(NSString *)audioFile
{
    return [[[self alloc] initWithFile:file name:name audioFile:audioFile] autorelease];
}

- (id) initWithFile:(NSString *)file name:(NSString *)name audioFile:(NSString *)audioFile
{
    if (self = [super initWithFile:file])
    {
        self.name = name;
        self.audioFile = audioFile;
        
        if (self.audioFile)
        {
            [[SimpleAudioEngine sharedEngine] preloadEffect:self.audioFile];
        }
    }
    return self;
}

- (void) dealloc
{
    if (_audioFile)
    {
        [[SimpleAudioEngine sharedEngine] unloadEffect:_audioFile];
        
        [_audioFile release];
        _audioFile = nil;
    }
    
    [_name release];
    _name = nil;
    
    [super dealloc];
}

@end

#define BLINK_ACTION_TAG 10

@implementation Gardenlayer
{
    NSMutableDictionary *gardenObjectPositions;
    
    NSInteger t_zOrder;
    
    DLSubtitleLabel *content;
    
    CCNode *targetNode;
}

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [[self class] node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    self = [super init];
    NSAssert(self, @"failed to initiate GardenLayer");
    
    gardenObjectPositions = [[NSMutableDictionary alloc] init];
    
    t_zOrder = NSIntegerMin;
    
    CCSprite *back = [CCSprite spriteWithFile:@"garden_background.png"];
    back.anchorPoint = CGPointZero;
    [self addChild:back z:t_zOrder++];
    
    NSDictionary *data = @{@"green beans": @{@"file": @"bean.png",
                                      @"position":@"{360.9,180.1}",
                                      @"audio":@"beans.mp3"},
                           @"a gate": @{@"file": @"gate.png",
                                      @"position":@"{676.7,202.3}",
                                      @"audio":@"gate.mp3"},
                           @"grapes": @{@"file": @"grape.png",
                                      @"position":@"{142.7,222}",
                                      @"audio":@"grapes.mp3"},
                           @"a glove": @{@"file": @"glove.png",
                                       @"position":@"{464.5,253.5}",
                                       @"audio":@"glove.mp3"},
                           @"grass": @{@"file": @"grass.png",
                                       @"position":@"{504.8,130.2}",
                                       @"audio":@"grass.mp3"},
                           @"grasshopper": @{@"file": @"locust.png",
                                       @"position":@"{861.5,350}",
                                       @"audio":@"grasshopper.mp3"}};
    [self createGardenWithData:data];
    
    content = [DLSubtitleLabel labelWithString:@" " fntFile:@"Didot.fnt"];
    content.anchorPoint = ccp(0, 0.5);
    CGSize s_size = [[CCDirector sharedDirector] winSize];
    CGPoint s_point = ccpFromSize(s_size);
    content.position = ccpCompMult(s_point, ccp(0.16, 0.7));
    
    content.delegate = self;
    content.touchEnable = YES;
//    content.color = ccBLACK;
    [self addChild:content z:NSIntegerMax - 1];
    [self resetContent];
    
    targetNode = [CCNode node];
    targetNode.contentSize = CGSizeMake(10, 10);
    targetNode.position = ccpCompMult(s_point,ccp(0.7,0.66));
    [self addChild:targetNode z:t_zOrder++];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    [gardenObjectPositions release];
}

- (void) createGardenWithData:(NSDictionary*)data
{
    for (NSString *name in data.allKeys)
    {
        NSDictionary *info = [data objectForKey:name];
        NSString *file = [info objectForKey:@"file"];
        CGPoint position = CGPointFromString([info objectForKey:@"position"]);
        NSString *audio = [info objectForKey:@"audio"];
        
        GardenObject *object = [GardenObject objectWithFile:file name:name audioFile:audio];
        object.position = position;
        
        [self addChild:object z:t_zOrder++];
        object.delegate = self;
        object.isDraggable = YES;
        
        [gardenObjectPositions setValue:[info objectForKey:@"position"] forKey:name];
        
        //blink
        CCFadeTo *fade_out = [CCFadeTo actionWithDuration:0.8 opacity:255/2.5];
        CCFadeTo *fade_in = [CCFadeTo actionWithDuration:0.8 opacity:255];
        CCSequence *s = [CCSequence actions:fade_out,fade_in, nil];
        CCRepeatForever *r = [CCRepeatForever actionWithAction:s];
        r.tag = BLINK_ACTION_TAG;
        [object runAction:r];
    }
}

- (void) resetContent
{
    [content setString:@"My garden has ___"];
}

- (void) fillContentWithString:(NSString*)string
{
    [self resetContent];
    [content setString:[NSString stringWithFormat:@"My garden has %@.",string]];
}

- (void) moveObjectToOriginalPosition:(GardenObject*)object done:(void (^)())moveDoneBlock
{
    CGPoint pos = CGPointFromString([gardenObjectPositions objectForKey:object.name]);
    CGFloat length = ccpLength(ccpSub(object.position, pos));
    CGFloat speed = 300;
    CGFloat duration = length/speed;
    
    CCMoveTo *move = [CCMoveTo actionWithDuration:duration position:pos];
    CCEaseBackIn *ease = [CCEaseBackIn actionWithAction:move];
    
    CCCallBlock *block = [CCCallBlock actionWithBlock:moveDoneBlock];
    
    CCSequence *seq = [CCSequence actions:ease,block, nil];
    [object runAction:seq];
}

#pragma mark --DLDraggableSpriteDelegate

- (void) draggableSpriteStartMove:(id)sender
{
    GardenObject *object = sender;
    object.zOrder = t_zOrder++;
    
    if ([object getActionByTag:BLINK_ACTION_TAG])
    {
        [object stopActionByTag:BLINK_ACTION_TAG];
        object.opacity = 255;
    }
    
    [self resetContent];
}

- (void) draggableSpriteEndMove:(id)sender
{
    GardenObject *object = sender;
    CGRect objectRect = object.boundingBox;
    
    void (^block)() = ^void(){
        // do nothing
    };
    if (CGRectContainsRect(objectRect,targetNode.boundingBox))
    {
        [self fillContentWithString:object.name];
        [[SimpleAudioEngine sharedEngine] playEffect:object.audioFile];
        
        Block_release(block);
        block = ^void(){
//            [self resetContent];
        };
    }
    
    [self moveObjectToOriginalPosition:object done:block];
}

#pragma mark --DLSubtitleLabelDelegate

- (void) subtitleLabelClickOnWord:(NSString *)word sender:(id)sender
{
    CCLOG(@"%@",word);
}

@end
