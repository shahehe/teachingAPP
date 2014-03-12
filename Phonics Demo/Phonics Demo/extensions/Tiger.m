//
//  Tiger.m
//  Letter Games HD
//
//  Created by USTB on 12-11-29.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Tiger.h"


@implementation Tiger

+ (id) newTiger
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"catAnimation.plist"];
    return [[[self alloc] initTiger] autorelease];
}

- (id) initTiger
{
    if (self = [super initWithSpriteFrameName:@"cat.png"])
    {
        currentAnimate = nil;
    }
    return self;
}

- (void) speakWithDuration:(ccTime)_duration
{
    if (currentAnimate)
    {
        [self stopAction:currentAnimate];
        currentAnimate = nil;
    }
    
    ccTime timePerFrame = 0.5f;
    NSUInteger times = MAX(_duration/timePerFrame,1);
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:2];
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    CCSpriteFrame *frame01 = [frameCache spriteFrameByName:@"catsmile.png"];
    CCSpriteFrame *frame02 = [frameCache spriteFrameByName:@"cat.png"];
    //CCSpriteFrame *frame03 = [frameCache spriteFrameByName:@"cat.png"];
    [frames addObject:frame01];
    [frames addObject:frame02];
    
    CCAnimation *anim = [CCAnimation animationWithSpriteFrames:frames delay:timePerFrame];
    CCAnimate *animate = [CCAnimate actionWithAnimation:anim];
    CCRepeat *repeat = [CCRepeat actionWithAction:animate times:times];
    
    CCCallBlock *actionDone = [CCCallBlock actionWithBlock:^{
        currentAnimate = nil;
        //[self setDisplayFrame:frame03];
    }];
    
    CCSequence *seq = [CCSequence actions:repeat,actionDone, nil];
    
    [self runAction:seq];
    
    currentAnimate = seq;
}

- (void) wagsTailWithDuration:(ccTime)_duration
{
    if (currentAnimate)
    {
        [self stopAction:currentAnimate];
        currentAnimate = nil;
    }
    
    ccTime timePerFrame = 0.1f;
    NSUInteger times = MAX(_duration/timePerFrame,1);
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:2];
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    CCSpriteFrame *frame01 = [frameCache spriteFrameByName:@"cattail1.png"];
    CCSpriteFrame *frame02 = [frameCache spriteFrameByName:@"cattail2.png"];
    [frames addObject:frame01];
    [frames addObject:frame02];
    
    CCAnimation *anim = [CCAnimation animationWithSpriteFrames:frames delay:timePerFrame];
    CCAnimate *animate = [CCAnimate actionWithAnimation:anim];
    CCRepeat *repeat = [CCRepeat actionWithAction:animate times:times];
    
    CCCallBlock *actionDone = [CCCallBlock actionWithBlock:^{
        currentAnimate = nil;
    }];
    
    CCSequence *seq = [CCSequence actions:repeat,actionDone, nil];
    
    [self runAction:seq];
    
    currentAnimate = seq;

}

- (void) shakingHeadWithDuration:(ccTime)_duration
{
    if (currentAnimate)
    {
        [self stopAction:currentAnimate];
        currentAnimate = nil;
    }
    
    ccTime timePerFrame = 0.2f;
    NSUInteger times = MAX(_duration/timePerFrame,1);
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:2];
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    CCSpriteFrame *frame01 = [frameCache spriteFrameByName:@"catright.png"];
    CCSpriteFrame *frame02 = [frameCache spriteFrameByName:@"catleft.png"];
    CCSpriteFrame *frame03 = [frameCache spriteFrameByName:@"cat.png"];
    [frames addObject:frame01];
    [frames addObject:frame02];
    //[frames addObject:frame03];
    
    CCAnimation *anim = [CCAnimation animationWithSpriteFrames:frames delay:timePerFrame];
    CCAnimate *animate = [CCAnimate actionWithAnimation:anim];
    CCRepeat *repeat = [CCRepeat actionWithAction:animate times:times];
    
    CCCallBlock *actionDone = [CCCallBlock actionWithBlock:^{
        currentAnimate = nil;
        [self setDisplayFrame:frame03];
    }];
    
    CCSequence *seq = [CCSequence actions:repeat,actionDone, nil];
    
    [self runAction:seq];
    
    currentAnimate = seq;
}

- (void) dealloc
{
    [self stopAllActions];
    [super dealloc];
}

@end
