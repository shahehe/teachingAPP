//
//  TouchGameWill.m
//  LetterE
//
//  Created by yiplee on 14-4-14.
//  Copyright 2014年 USTB. All rights reserved.
//
static char *const file = "will.plist";

#import "config.h"
#import "TouchGameWill.h"

@interface TouchGameWill ()
{
    CCSprite *boy;
    CCSprite *duck;
    CCSprite *think;
    
    CGPoint _speed;
}

@property(nonatomic,assign) CGPoint speed;

@end

@implementation TouchGameWill

@synthesize speed = _speed;

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
    
    CCSprite *fg_left = [CCSprite spriteWithFile:@"fg_left.png"];
    fg_left.anchorPoint = ccp(0, 0);
    fg_left.position = CMP(0);
    fg_left.zOrder = 3;
    [self addChild:fg_left];
    
    CCSprite *fg_right = [CCSprite spriteWithFile:@"fg_right.png"];
    fg_right.anchorPoint = ccp(1, 0);
    fg_right.position = CCMP(1, 0);
    fg_right.zOrder = 3;
    [self addChild:fg_right];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"boy.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"duck.plist"];
    
    boy = [CCSprite spriteWithSpriteFrameName:@"boy0.png"];
    boy.position = CCMP(0.38,0.451);
    boy.zOrder = 2;
    [self addChild:boy];
    
    duck = [CCSprite spriteWithSpriteFrameName:@"duck.png"];
    duck.position = CCMP(0.7, 0.401);
    duck.zOrder = 2;
    [self addChild:duck];
    
    @autoreleasepool {
        CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:@"star_on.png"];
        CGRect rect = CGRectZero;
        rect.size = tex.contentSize;
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame name:@"star_on"];
    }
    
    @autoreleasepool {
        CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:@"star_off.png"];
        CGRect rect = CGRectZero;
        rect.size = tex.contentSize;
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame name:@"star_off"];
    }
    
    [self setObjectLoadedBlock:^(GameObject *object) {
        object.zOrder = 4;
        CCSprite *star = [CCSprite spriteWithSpriteFrameName:@"star_off"];
        star.position = ccpAdd(object.position, ccp(-100, 0));
        star.zOrder = object.zOrder;
        [object.parent addChild:star];
        object.userObject = star;
    }];
    
    [self setObjectActivedBlock:^(GameObject *object) {
        blinkSprite(object);
//        NSString *name = [[object.name componentsSeparatedByString:@"-"] lastObject];
        CCLabelTTF *label = [CCLabelTTF labelWithString:object.name fontName:@"GillSans" fontSize:32];
        label.color = ccBLACK;
        label.position = ccpMult(ccpFromSize(object.boundingBox.size), 0.5);
        [object addChild:label];
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        unblinkSprite(object);
        ((CCSprite*)object.userObject).displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"star_on"];
    }];
    
    [self setAutoActiveNext:NO];
    
    return self;
}

- (void) update:(ccTime)delta
{
    if (duck.position.x < SCREEN_WIDTH * 0.6)
    {
        duck.flipX = YES;
    }
    else if (duck.position.x > SCREEN_WIDTH * 0.9)
    {
        duck.flipX = NO;
    }
    
    CGPoint s = ccpMult(_speed, duck.flipX ? 1:-1);
    CGPoint offset = ccpMult(s, delta);
    duck.position = ccpAdd(duck.position, offset);
}

- (void) onExit
{
    [super onExit];
    [self unscheduleUpdate];
}

- (void) dealloc
{
    [super dealloc];
}

- (void) cleanCache
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"boy.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"duck.plist"];
    
    [super cleanCache];
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;
    
    [self boyTalk];
    duck.flipX = NO;
    [self resetDuck];

    return YES;
}

- (void) contentDidFinishReading:(GameObject *)object
{
    [self activeNextObjects];
    
    [self boyStopTalk];
    
    if ([object.name hasSuffix:@"quack"])
    {
        [self duckActionForQuack];
    }
    else if ([object.name hasSuffix:@"quiet"])
    {
        [self duckActionForQuiet];
    }
    else if ([object.name hasSuffix:@"quiz"])
    {
        [self duckActionForQuiz];
    }
    else
    {
        [self duckActionForQuickly];
    }
    
}

- (void) boyTalk
{
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame *f0 = [cache spriteFrameByName:@"boy0.png"];
    CCSpriteFrame *f1 = [cache spriteFrameByName:@"boy1.png"];
    CCSpriteFrame *f2 = [cache spriteFrameByName:@"boy2.png"];
    NSArray *frames = @[f0,f1,f2,f1,f0];
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.2];
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    
    [boy stopAllActions];
    [boy runAction:[CCRepeatForever actionWithAction:animate]];
}

- (void) boyStopTalk
{
    [boy stopAllActions];
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame *f0 = [cache spriteFrameByName:@"boy0.png"];
    boy.displayFrame = f0;
}

- (void) resetDuck
{
    [self unscheduleUpdate];
    [duck stopAllActions];
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck.png"];
    
    duck.displayFrame = f0;
    
    [think removeFromParentAndCleanup:YES];
    think = nil;
}

- (void) duckActionForQuack
{
    duck.flipX = NO;
    [self resetDuck];
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCAnimate *animate1 = nil;
    {
        CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck.png"];
        CCSpriteFrame *f1 = [cache spriteFrameByName:@"duck_node_1.png"];
        CCSpriteFrame *f2 = [cache spriteFrameByName:@"duck_node_2.png"];
        
        NSArray *frames = @[f0,f1,f2,f1,f0];
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.2];
        animate1 = [CCAnimate actionWithAnimation:animation];
    }
    
    CCAnimate *animate2 = nil;
    {
        CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck.png"];
        CCSpriteFrame *f1 = [cache spriteFrameByName:@"duck_speak1.png"];
        
        NSArray *frames = @[f0,f1,f0];
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.2];
        animate2 = [CCAnimate actionWithAnimation:animation];
    }
    
    __block id duck_copy = duck;
    CCCallBlock *nodDone = [CCCallBlock actionWithBlock:^{
        [duck_copy runAction:[CCRepeatForever actionWithAction:animate2]];
    }];
    
    CCSequence *seq = [CCSequence actions:animate1,nodDone, nil];
    
    [duck runAction:seq];
}

- (void) duckActionForQuiet
{
    duck.flipX = NO;
    [self resetDuck];
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCAnimate *animate1 = nil;
    {
        CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck.png"];
        CCSpriteFrame *f1 = [cache spriteFrameByName:@"duck_node_1.png"];
        CCSpriteFrame *f2 = [cache spriteFrameByName:@"duck_node_2.png"];
        
        NSArray *frames = @[f0,f1,f2,f1,f0];
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.2];
        animate1 = [CCAnimate actionWithAnimation:animation];
    }

    [duck runAction:animate1];
}

- (void) duckActionForQuiz
{
    duck.flipX = NO;
    [self resetDuck];
    
    think = [CCSprite spriteWithSpriteFrameName:@"duck_think.png"];
    think.anchorPoint = ccp(0.3,0.3);
    think.position = ccp(CGRectGetMaxX(duck.boundingBox), CGRectGetMaxY(duck.boundingBox));
    [self addChild:think];
    
    CCSequence *seq1 = [CCSequence actions:[CCFadeIn actionWithDuration:0.5],[CCDelayTime actionWithDuration:1],[CCFadeOut actionWithDuration:0.5], nil];
    [think runAction:seq1];
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCAnimate *shakeHead = nil;
    {
        CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck.png"];
        CCSpriteFrame *f1 = [cache spriteFrameByName:@"duck_shake1.png"];
        CCSpriteFrame *f2 = [cache spriteFrameByName:@"duck_shake2.png"];
        NSArray *frames = @[f0,f1,f2,f1,f0];
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.2];
        shakeHead = [CCAnimate actionWithAnimation:animation];
    }
    
    CCAnimate *run = nil;
    {
        CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck_run0.png"];
        CCSpriteFrame *f1 = [cache spriteFrameByName:@"duck_run1.png"];
        CCSpriteFrame *f2 = [cache spriteFrameByName:@"duck_run2.png"];
        CCSpriteFrame *f3 = [cache spriteFrameByName:@"duck_run3.png"];
        NSArray *frames = @[f0,f1,f2,f3,f2,f1,f0];
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.35];
        run = [CCAnimate actionWithAnimation:animation];
    }
    
    __block TouchGameWill *self_copy = self;
    
    CCDelayTime *wait = [CCDelayTime actionWithDuration:2];
    CCCallBlock *shakeDone = [CCCallBlock actionWithBlock:^{
        [self_copy->duck runAction:[CCRepeatForever actionWithAction:run]];
        [self_copy->duck setFlipX:YES];
        [self_copy setSpeed:ccp(80, 0)];
        [self_copy scheduleUpdate];
    }];
    
    CCSequence *seq2 = [CCSequence actions:wait,shakeHead,shakeDone, nil];
    [duck runAction:seq2];
}

- (void) duckActionForQuickly
{
    duck.flipX = NO;
    [self resetDuck];
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCAnimate *run = nil;
    {
        CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck_run0.png"];
        CCSpriteFrame *f1 = [cache spriteFrameByName:@"duck_run1.png"];
        CCSpriteFrame *f2 = [cache spriteFrameByName:@"duck_run2.png"];
        CCSpriteFrame *f3 = [cache spriteFrameByName:@"duck_run3.png"];
        NSArray *frames = @[f0,f1,f2,f3,f2,f1,f0];
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.2];
        run = [CCAnimate actionWithAnimation:animation];
    }
    
    [duck runAction:[CCRepeatForever actionWithAction:run]];
    duck.flipX = YES;
    
    _speed = ccp(160, 0);
    [self scheduleUpdate];
}

@end
