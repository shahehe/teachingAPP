//
//  TouchGameFound.m
//  LetterE
//
//  Created by yiplee on 14-3-27.
//  Copyright (c) 2014年 USTB. All rights reserved.
//
static char *const file = "found.plist";

#import "config.h"
#import "TouchGameFound.h"

@interface TouchGameFound ()
{
    CCSprite *card;
    CCSprite *chest;
    
    CCSprite *shine;
}

@end

@implementation TouchGameFound

+ (TouchGameFound *) gameLayer
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
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"found.plist"];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    
    chest = [CCSprite spriteWithSpriteFrameName:@"chest.png"];
    chest.position = CCMP(0.459, 0.643);
    chest.zOrder = 2;
    [self addChild:chest];
    
    shine = [CCSprite spriteWithFile:@"blue_shine.png"];
    shine.anchorPoint = ccp(0.602, 0.427);
    shine.position = CCMP(0.53, 0.537);
    shine.zOrder = 1;
    [self addChild:shine];
    shine.opacity = 0;
    
    self.autoActiveNext = NO;
    [self setTouchEnabled:YES];
    
    __block TouchGameFound *self_copy = self;
    [self setObjectLoadedBlock:^(GameObject *object) {
        object.visible = NO;
    }];
    
    [self setObjectActivedBlock:^(GameObject *object) {
        object.visible = YES;
        blinkSprite(object);
        
        [self_copy resetChest];
        
        CCSpriteFrame *f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:object.name];
        if(self_copy->card)
        {
            self_copy->card.displayFrame = f;
        }
        else
        {
            self_copy->card = [CCSprite spriteWithSpriteFrame:f];
            [self_copy addChild:self_copy->card];
        }
        
        [self_copy resetCard];
        [[self_copy contentLabel] setString:@"  "];
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        unblinkSprite(object);
    }];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) update:(ccTime)delta
{
    shine.opacity = ((int)(shine.opacity + 100*delta)) % 255;
}

- (void) onEnter
{
    [super onEnter];
    
    [self scheduleUpdate];
    
//    [[CCTextureCache sharedTextureCache] addImageAsync:@"particle-star.png" withBlock:^(CCTexture2D *tex) {
//        
//    }];
}

- (void) onExit
{
    [super onExit];
    
    [chest stopAllActions];
    [self unscheduleUpdate];
}

- (void) resetCard
{
    if (card)
    {
        card.zOrder = 3;
        card.position = CCMP(0.516, 0.632);
        card.scale = 0.1;
        card.opacity = 0;
        
        [card stopAllActions];
    }
}

- (void) resetChest
{
    [chest stopAllActions];
    CCSpriteFrame *f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"chest.png"];
    chest.displayFrame = f;
}

- (void) setGameMode:(TouchGameMode)gameMode
{
    // do nothing
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if (![super objectHasBeenClicked:object])
        return NO;
    
    object.visible = NO;
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:object];
    
    CCSpriteFrame *f1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"chest.png"];
    CCSpriteFrame *f2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"chest_half_open.png"];
    CCSpriteFrame *f3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"chest_open.png"];
    NSArray *frames = @[f1,f2,f3];
    CCAnimation *ani = [CCAnimation animationWithSpriteFrames:frames delay:0.1];
    CCAnimate *animate = [CCAnimate actionWithAnimation:ani];
    
    CCFadeIn *fade = [CCFadeIn actionWithDuration:2];
    CCMoveBy *move = [CCMoveBy actionWithDuration:2 position:ccp(0, 100)];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:2 scale:1];
    
    __block CCSprite *card_copy = card;
    CCCallBlock *animationDone = [CCCallBlock actionWithBlock:^{
        [card_copy runAction:fade];
        [card_copy runAction:move];
        [card_copy runAction:scale];
        
        object.tag = 3;
    }];
    
    CCSequence *seq = [CCSequence actions:animate,animationDone, nil];
    [chest runAction:seq];
    
    return YES;
}

#pragma mark --touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.runningObject.tag > 2)
        [self activeNextObjects];
}


@end
