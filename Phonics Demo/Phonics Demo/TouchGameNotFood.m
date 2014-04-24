//
//  TouchGameNotFood.m
//  LetterE
//
//  Created by yiplee on 14-4-24.
//  Copyright 2014年 USTB. All rights reserved.
//
static char *const file = "notFood.plist";

#import "config.h"
#import "TouchGameNotFood.h"

@implementation TouchGameNotFood
{
    CCArray *foods;
    CGPoint startPos;
    
    CCSprite *lastFood; // weak ref
    
    CCSprite *dog; //weak ref
    CCSprite *cat; //weak ref
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
    
    CCSprite *fg = [CCSprite spriteWithFile:@"fg.pvr.ccz"];
    fg.scale = SCREEN_WIDTH / fg.contentSize.width;
    fg.zOrder = 5;
    fg.position = CMP(0.5);
    [self addChild:fg];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"objects.plist"];
    foods = [[CCArray alloc] init];
    startPos = CCMP(1.074, 0.450);
    NSArray *foodNames = @[@"Sushi",@"cake",@"cookie",@"fish",@"ice_cream",@"rice"];
    for (NSString *name in foodNames)
    {
        CCSprite *food = [CCSprite spriteWithSpriteFrameName:name];
        food.visible = NO;
        [self addChild:food];
        [foods addObject:food];
    }
    
    dog = [CCSprite spriteWithSpriteFrameName:@"dog"];
    dog.position = CCMP(0.106, 0.146);
    dog.zOrder = 4;
    [self addChild:dog];
    
    cat = [CCSprite spriteWithSpriteFrameName:@"cat"];
    cat.position = CCMP(0.872, 0.138);
    cat.zOrder = 4;
    [self addChild:cat];
    
    __block TouchGameNotFood *self_copy = self;
    [self setObjectLoadedBlock:^(GameObject *object) {
        object.visible = NO;
        
        CCSprite *image = [CCSprite spriteWithSpriteFrameName:object.name];
        image.position = CCMP(0.5,0.65);
        object.userObject = image;
    }];
    
    [self setObjectActivedBlock:^(GameObject *object) {
        [self_copy->foods addObject:object];
    }];
    
    [[self contentLabel] setZOrder:6];
    [[self contentLabel] setScale:0.8];
    
    [self setGameMode:GameModeAllAtOnce];
    [self setAutoActiveNext:NO];
    
    [self setTouchEnabled:YES];
    
    [self scheduleUpdate];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    [foods release];

    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

- (void) cleanCache
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"objects.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"object.png"];
    
    [super cleanCache];
}

- (void) update:(ccTime)delta
{
    CGPoint speed = ccp(-200, -25);
    for (CCSprite *food in foods)
    {
        if (!food.visible)
            continue;
        
        if (CGRectGetMaxX(food.boundingBox) <= 0)
        {
            food.visible = NO;
        }
        
        CGPoint s = speed;
        if (food.position.x < SCREEN_WIDTH/2)
        {
            s = ccpCompMult(s, ccp(1, -1));
        }
        
        food.position = ccpAdd(food.position, ccpMult(s, delta));
    }
    
    if (!lastFood || !lastFood.visible || CGRectGetMaxX(lastFood.boundingBox) < SCREEN_WIDTH-40)
    {
        CCSprite *newFood = [self randomAvailableFood];
        if (newFood)
        {
            newFood.visible = YES;
            newFood.position = startPos;
            
            lastFood = newFood;
        }
    }
}

- (CCSprite *) randomAvailableFood
{
    NSUInteger count = foods.count;
    NSUInteger idx = arc4random_uniform(count);
    
    for (int i=0;i<count;i++)
    {
        NSUInteger t = (idx+i) % count;
        CCSprite *food = [foods objectAtIndex:t];
        
        if (food.visible || food.tag >= 2)
            continue;
        
        return food;
    }
    
    return nil;
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;
    
    object.visible = NO;
    
    CCSprite *image = object.userObject;
    image.visible = YES;
    image.opacity = 255;
    image.scale = 0;
    [self addChild:image];
    [image runAction:[CCFadeIn actionWithDuration:0.5]];
    [image runAction:[CCScaleTo actionWithDuration:0.5 scale:1]];
    
    CCSprite *shine = [CCSprite spriteWithSpriteFrameName:@"shine"];
    shine.anchorPoint = ccp(0.581,0.421);
    shine.position = image.position;
    shine.zOrder = 2;
    [self addChild:shine];
    
    [shine runAction:[CCFadeOut actionWithDuration:0.6]];
    [shine performSelector:@selector(removeFromParent) withObject:nil afterDelay:0.65];
    
    [self unscheduleUpdate];
    
    if ([object.name isEqualToString:@"nut"])
    {
        //right
        
        //dog
        {
            CCSpriteFrame *f1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dog"];
            CCSpriteFrame *f2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dog-1"];
            NSArray *frames = @[f1,f2,f1];
            
            CCAnimation *a = [CCAnimation animationWithSpriteFrames:frames delay:0.25];
            CCAnimate *t = [CCAnimate actionWithAnimation:a];
            [dog runAction:[CCRepeat actionWithAction:t times:2]];
        }
        
        //cat
        {
            CCSpriteFrame *f1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"cat"];
            CCSpriteFrame *f2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"cat-1"];
            NSArray *frames = @[f1,f2,f1];
            
            CCAnimation *a = [CCAnimation animationWithSpriteFrames:frames delay:0.25];
            CCAnimate *t = [CCAnimate actionWithAnimation:a];
            [cat runAction:[CCRepeat actionWithAction:t times:2]];
        }
    }
    else
    {
        //wrong
        
        //dog
        CCSpriteFrame *f1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dog"];
        CCSpriteFrame *f2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dog-2"];
        CCSpriteFrame *f3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dog-3"];
        NSArray *frames = @[f1,f2,f3,f2,f1];
        
        CCAnimation *a = [CCAnimation animationWithSpriteFrames:frames delay:0.25];
        CCAnimate *t = [CCAnimate actionWithAnimation:a];
        [dog runAction:[CCRepeat actionWithAction:t times:2]];
    }
    
    return YES;
}

#pragma mark --touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:-2
                                                       swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCSprite *image = self.runningObject.userObject;
    if (image.parent)
        return YES;
    
    return NO;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCSprite *image = self.runningObject.userObject;
    CGPoint pos = [image.parent convertTouchToNodeSpace:touch];
    
    if (CGRectContainsPoint(image.boundingBox, pos))
    {
        [image runAction:[CCFadeOut actionWithDuration:0.5]];
        
        CCMoveBy *move = [CCMoveBy actionWithDuration:0.55 position:ccp(0, SCREEN_HEIGHT/2)];
        CCCallBlock *moveDone = [CCCallBlock actionWithBlock:^{
            [image removeFromParentAndCleanup:YES];
            [self scheduleUpdate];
        }];
        
        [image runAction:[CCSequence actions:move,moveDone, nil]];
    }
}

@end
