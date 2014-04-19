//
//  TouchGameZoo.m
//  LetterE
//
//  Created by yiplee on 14-4-19.
//  Copyright 2014年 USTB. All rights reserved.
//
static char *const file = "zoo.plist";

#import "config.h"
#import "TouchGameZoo.h"

@implementation TouchGameZoo
{
    GameObject *previous;
    GameObject *next;
    
    CGPoint previousPos;
    CGPoint nextPos;
    
    CCSpriteFrame *previousFrame;
    CCSpriteFrame *nextFrame;
    
    NSInteger index;
}

+ (instancetype) gameLayer
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
    
    CCLabelTTF *title = [CCLabelTTF labelWithString:self.gameTitle fontName:@"ChalkboardSE-Bold" fontSize:240];
    title.color = ccBLACK;
    title.position = CMP(0.5);
    title.tag = NSIntegerMin;
    [self addChild:title];
    
    CCScaleBy *scale = [CCScaleBy actionWithDuration:1.2 scale:0.6];
    [title runAction:[CCEaseBounceOut actionWithAction:scale]];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"zoo.plist"];
    
    NSDictionary *zooObjects = @{@"butterflies":@{@"butterfly-1.png": @"{0.149,0.759}",
                                                @"butterfly-2.png": @"{0.623,0.698}",
                                                @"butterfly-3.png": @"{0.827,0.328}",
                                                @"butterfly-4.png": @"{0.833,0.535}",},
                                 @"zebras":   @{@"zebras-1.png":@"{0.231,0.437}",
                                                @"zebras-2.png":@"{0.45,0.315}",
                                                @"zebras-3.png":@"{0.692,0.512}"},
                                 @"zookeeper":@{@"zookeeper-1.png":@"{0.401,0.391}",
                                                @"zookeeper-2.png":@"{0.724,0.366}"},
                                 @"zoologist":@{@"zoologist.png":@"{0.207,0.486}"}
                                 };
    
    [self setObjectLoadedBlock:^(GameObject *object) {
        object.visible = NO;
        
        NSDictionary *images = [zooObjects objectForKey:object.name];
        CCArray *zooObjects = [CCArray arrayWithCapacity:images.count];
        
        for (NSString *file in images.allKeys)
        {
            CCSprite *s = [CCSprite spriteWithSpriteFrameName:file];
            CGPoint p = CGPointFromString([images valueForKey:file]);
            s.position = CCMP(p.x, p.y);
            s.tag = NSIntegerMin;
            
            [zooObjects addObject:s];
        }
        
        object.userObject = zooObjects;
    }];
    
    __block TouchGameZoo *self_copy = self;
    [self setObjectActivedBlock:^(GameObject *object) {
        object.visible = YES;
        self_copy->next = object;
    }];
    
    [self.contentLabel setScale:0.9];
    previousPos = CCMP(0.109,0.067);
    nextPos = CCMP(0.891,0.067);
    
    previousFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"previous_page.png"];
    nextFrame     = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"next_page.png"];
    
    index = -1;
    self.autoActiveNext = YES;
    
    return self;
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;
    
    if (object == previous)
    {
        index --;
        next.visible = NO;
    }
    else // next
    {
        index ++;
        previous.visible = NO;
    }
    
    previous = [self gameObjectAtIndex:index-1];
    previous.displayFrame = previousFrame;
    previous.position = previousPos;
    previous.visible = YES;
    
    next = [self gameObjectAtIndex:index+1];
    next.displayFrame = nextFrame;
    next.position = nextPos;
    next.visible = YES;
    
    object.visible = NO;
    
    CCArray *children = [self.children copy];
    for (CCNode *child in children)
    {
        if (child.tag == NSIntegerMin)
            [child removeFromParentAndCleanup:YES];
    }
    
    [children release];
    
    CCArray *zooObjects = object.userObject;
    for (CCSprite *image in zooObjects)
    {
        [self addChild:image];
        image.scale = 0;
        CCScaleTo *scale = [CCScaleTo actionWithDuration:0.6 scale:1];
        [image runAction:[CCEaseBounceOut actionWithAction:scale]];
    }
    
    return YES;
}

- (void) cleanCache
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"zoo.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"zoo.pvr.ccz"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"next_page.png"];
    
    [super cleanCache];
}

@end
