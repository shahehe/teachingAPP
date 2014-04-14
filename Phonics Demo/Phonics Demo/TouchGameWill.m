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

@implementation TouchGameWill
{
    CCSprite *boy;
    CCSprite *duck;
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
    boy.position = CCMP(0.443,0.451);
    boy.zOrder = 2;
    [self addChild:boy];
    
    duck = [CCSprite spriteWithSpriteFrameName:@"duck"];
    duck.position = CCMP(0.822, 0.401);
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
        CCLabelTTF *label = [CCLabelTTF labelWithString:object.name fontName:@"GillSans" fontSize:24];
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

- (void) dealloc
{
    [super dealloc];
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;

    return YES;
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
    [duck stopAllActions];
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck"];
    
    duck.displayFrame = f0;
//    duck.position = CCMP(0.822, 0.401);
    duck.anchorPoint = ccp(0.5, 0.5);
}

- (void) duckActionForQuack
{
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck"];
    CCSpriteFrame *f1 = [cache spriteFrameByName:@"duck_node_1"];
    CCSpriteFrame *f2 = [cache spriteFrameByName:@"duck_node_2"];
    
    NSArray *frames = @[f0,f1,f2,f1,f0];
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.2];
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    
    
}

- (void) duckShake
{
    duck.anchorPoint = ccp(0.486, 0.568);
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame *f0 = [cache spriteFrameByName:@"duck_shake1"];
    CCSpriteFrame *f1 = [cache spriteFrameByName:@"duck_shake2"];
    
    NSArray *frames = @[f0,f1,f0];
    
}

@end
