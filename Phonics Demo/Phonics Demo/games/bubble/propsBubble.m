//
//  propsBubble.m
//  bubble
//
//  Created by yiplee on 13-4-2.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import "propsBubble.h"


@implementation propsBubble

- (id) initWithPropsInside:(CCPhysicsSprite *)object
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bubble_object.plist"];
    if (self = [super initWithObjectInside:object])
    {
        self.bubbleType = BubbleTypeProps; // 道具泡泡
        
        _score = 0;
        _coin = 0;
        _time = 0;
        _live = 0;
    }
    return self;
}

+ (propsBubble*) bubbleWithPropsInside:(CCPhysicsSprite *)props
{
    return [[[self alloc] initWithPropsInside:props] autorelease];
}

@end

#pragma mark -coin bubble

@implementation coinBubble

- (id) initBubbleWithCoin:(NSInteger)coinNumber
{
    CCPhysicsSprite *coin = [CCPhysicsSprite spriteWithSpriteFrameName:@"bubble_coin.png"];
    NSAssert(coin, @"coin sprite should not be nil");
    if (self = [self initWithPropsInside:coin])
    {
        self.coin = coinNumber;
    }
    return self;
}

+ (coinBubble*) coinBubbleWithCoin:(NSInteger)coinNumber
{
    return [[[self alloc] initBubbleWithCoin:coinNumber] autorelease];
}

+ (coinBubble*) coinBubble
{
    return [coinBubble coinBubbleWithCoin:1];
}

@end
