//
//  letterBubble.m
//  bubble
//
//  Created by yiplee on 13-4-1.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import "letterBubble.h"


@implementation letterBubble

- (id) initWithLetter:(NSString *)letter_
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bubble_object.plist"];
    NSString *imgName = [NSString stringWithFormat:@"bubble_%@.png",letter_];
    CCPhysicsSprite *object = [CCPhysicsSprite spriteWithSpriteFrameName:imgName];
    NSAssert(object, @"letterBubble:object should not be nil");
    if (self = [super initWithObjectInside:object])
    {
        self.bubbleType = BubbleTypeLetter; // 字母泡泡
        _letter = letter_;
        [_letter retain];
    }
    return self;
}

+ (letterBubble*) bubbleWithLetter:(NSString *)letter_
{
    return [[[self alloc] initWithLetter:letter_] autorelease];
}

- (void) dealloc
{
    [_letter release];
    _letter = nil;
    [super dealloc];
}

@end
