//
//  TouchGameWhere.m
//  LetterE
//
//  Created by yiplee on 14-4-23.
//  Copyright 2014年 USTB. All rights reserved.
//
static char *const file = "where.plist";

#import "config.h"
#import "TouchGameWhere.h"

@implementation TouchGameWhere
{
    NSArray *eggs;
    NSArray *egg_breaks;
    
    CCSprite *hammer;
    CGPoint hammerPos;
    
    NSUInteger currentIndex;
    NSUInteger runningObjectIndex;
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
    
    RGBA4444
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game_objects.plist"];
    PIXEL_FORMAT_DEFAULT
    
    CCSprite *egg1 = [CCSprite spriteWithSpriteFrameName:@"egg_1"];
    egg1.position = CCMP(0.2, 0.5);
    [self addChild:egg1];
    CCSprite *egg2 = [CCSprite spriteWithSpriteFrameName:@"egg_2"];
    egg2.position = CCMP(0.5, 0.5);
    [self addChild:egg2];
    CCSprite *egg3 = [CCSprite spriteWithSpriteFrameName:@"egg_3"];
    egg3.position = CCMP(0.8, 0.5);
    [self addChild:egg3];
    eggs = [@[egg1,egg2,egg3] retain];
    
    CCSprite *egg_break1 = [CCSprite spriteWithSpriteFrameName:@"egg_break_1"];
    CCSprite *egg_break2 = [CCSprite spriteWithSpriteFrameName:@"egg_break_2"];
    CCSprite *egg_break3 = [CCSprite spriteWithSpriteFrameName:@"egg_break_3"];
    egg_breaks = [@[egg_break1,egg_break2,egg_break3] retain];
    
    for (int i=0;i<eggs.count;i++)
    {
        CCSprite *s1 = [egg_breaks objectAtIndex:i];
        CCSprite *s2 = [eggs objectAtIndex:i];
        s1.anchorPoint = ccp(0.5, 0);
        s1.position = ccpAdd(s2.boundingBox.origin, ccp(s2.boundingBox.size.width/2,0));
        s1.visible = NO;
        [self addChild:s1];
    }
    
    hammer = [CCSprite spriteWithSpriteFrameName:@"hammer"];
    hammerPos = CCMP(0.9,0.1);
    hammer.position = hammerPos;
    [self addChild:hammer];
    
    currentIndex = 0;
    __block TouchGameWhere *self_copy = self;
    
    [self setObjectLoadedBlock:^(GameObject *object) {
        object.visible = NO;
    }];
    
    [self setObjectActivedBlock:^(GameObject *object) {
        object.visible = YES;
        [[self_copy contentLabel] setString:object.content];
        
        self_copy->currentIndex += 1;
        self_copy->runningObjectIndex = arc4random_uniform(3);
        CCSprite *egg = [self_copy->eggs objectAtIndex:self_copy->runningObjectIndex];
        egg.visible = NO;
        object.displayFrame = egg.displayFrame;
        object.position = egg.position;
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        // do nothing
    }];
    
    [self setAutoActiveNext:NO];
    [self setTouchEnabled:YES];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    [eggs release];
    [egg_breaks release];
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

- (void) cleanCache
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"game_objects.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"game_objects.pvr.ccz"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"egg_1.png"];
    
    [super cleanCache];
}

- (void) activeNextObjects
{
    for (int i=0;i<eggs.count;i++)
    {
        CCSprite *egg = [eggs objectAtIndex:i];
        egg.visible = YES;
        
        CCSprite *egg_break = [egg_breaks objectAtIndex:i];
        egg_break.visible = NO;
        egg_break.opacity = 255;
        
        CCSprite *node = egg_break.userObject;
        [node removeFromParentAndCleanup:YES];
        
        egg_break.userObject = nil;
    }
    
    [super activeNextObjects];
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;
    
    if (object.tag >= 3)
        return YES;
    
    [hammer stopAllActions];
    hammer.zOrder = 4;
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.6 position:object.position];
    
    __block TouchGameWhere *self_copy = self;
    CCCallBlock *moveDone = [CCCallBlock actionWithBlock:^{
        object.visible = NO;
        CCSprite *shine = [CCSprite spriteWithSpriteFrameName:@"shine"];
        shine.position = object.position;
        shine.zOrder = 3;
        [self_copy addChild:shine];
        [shine runAction:[CCFadeOut actionWithDuration:0.3]];
        [shine performSelector:@selector(removeFromParent) withObject:nil afterDelay:0.65];
        
        CCSprite *egg_break = [self_copy->egg_breaks objectAtIndex:self_copy->runningObjectIndex];
        egg_break.visible = YES;
        egg_break.zOrder = 2;
        [egg_break runAction:[CCFadeOut actionWithDuration:0.6]];
        
        CCSprite *image = [CCSprite spriteWithSpriteFrameName:object.name];
        image.position = object.position;
        image.zOrder = 1;
        [self_copy addChild:image];
        
        [image runAction:[CCFadeIn actionWithDuration:0.6]];
        egg_break.userObject = image;
        
        hammer.position = hammerPos;
    }];
    
    CCSequence *seq = [CCSequence actions:move,moveDone, nil];
    [hammer runAction:seq];
    
    return YES;
}

#pragma mark --touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:1
                                                       swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pos = [self convertTouchToNodeSpace:touch];
    
    for (int i=0;i<eggs.count;i++)
    {
        CCSprite *egg = [eggs objectAtIndex:i];
        if (!egg.visible)
            continue;
        
        if (CGRectContainsPoint(egg.boundingBox, pos))
        {
            [hammer stopAllActions];
            hammer.zOrder = 4;
            CCMoveTo *move = [CCMoveTo actionWithDuration:0.6 position:egg.position];
            
            __block TouchGameWhere *self_copy = self;
            CCCallBlock *moveDone = [CCCallBlock actionWithBlock:^{
                egg.visible = NO;
                CCSprite *shine = [CCSprite spriteWithSpriteFrameName:@"shine"];
                shine.position = egg.position;
                shine.zOrder = 3;
                [self_copy addChild:shine];
                [shine runAction:[CCFadeOut actionWithDuration:0.3]];
                [shine performSelector:@selector(removeFromParent) withObject:nil afterDelay:0.65];
                
                CCSprite *egg_break = [self_copy->egg_breaks objectAtIndex:i];
                egg_break.visible = YES;
                egg_break.zOrder = 2;
                [egg_break runAction:[CCFadeOut actionWithDuration:0.6]];
                
                CCSprite *box = [CCSprite spriteWithSpriteFrameName:@"box"];
                CGPoint box_p = ccpFromSize(box.boundingBox.size);
                box.position = ccpAdd(egg_break.position,ccp(0, 40));
                [self_copy addChild:box];
                
                CCSprite *spring = [CCSprite spriteWithSpriteFrameName:@"spring"];
                CGPoint spring_p = ccpFromSize(spring.boundingBox.size);
                spring.anchorPoint = ccp(0.5, 0);
                spring.scaleY = 0.3;
                spring.position = ccpCompMult(box_p, ccp(0.5, 0.9));
                [box addChild:spring];
                
                CCSprite *clown = [CCSprite spriteWithSpriteFrameName:@"clown"];
                clown.anchorPoint = ccp(0.5,0);
                clown.position = ccpCompMult(spring_p, ccp(0.5, 1));
                [spring addChild:clown];
                
                CCScaleTo *scale = [CCScaleTo actionWithDuration:0.6 scaleX:1 scaleY:1];
                [spring runAction:[CCEaseBounceOut actionWithAction:scale]];
                
                egg_break.userObject = box;
                
                hammer.position = hammerPos;
            }];
            
            CCSequence *seq = [CCSequence actions:move,moveDone, nil];
            [hammer runAction:seq];
            
            return;
        }
    }
    
    if (!self.runningObject.visible && currentIndex < self.objectCount)
    {
        [self activeNextObjects];
    }
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

@end
