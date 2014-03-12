//
//  WordCar.m
//  Letter Games HD
//
//  Created by USTB on 12-12-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WordCar.h"

static NSUInteger carsCount = 6;
static NSString *carNamePreffix = @"xiaoche";

@implementation WordCar

@synthesize word = _word;

+ (id) CarWithIndex:(NSUInteger)index andWord:(NSString *)word
{
    return [[[self alloc] initWithIndex:index andWord:word] autorelease];
}

- (id) initWithIndex:(NSUInteger)index andWord:(NSString *)word
{
    index = index % carsCount + 1;
    NSString *carNameString = [NSString stringWithFormat:@"%@%i.png",carNamePreffix,index];
    
    if (self = [super initWithSpriteFrameName:carNameString])
    {
        _word = word;
        
        wheel_1 = [CCSprite spriteWithSpriteFrameName:@"chelun.png"];
        wheel_2 = [CCSprite spriteWithSpriteFrameName:@"chelun.png"];
        
        CGSize size = self.contentSize;
        CGPoint point1 = ccp(size.width*0.25f, 0);
        CGPoint point2 = ccp(size.width*0.75f, 0);
        CGPoint center = ccp(size.width*0.5, size.height*0.5f);
        wheel_1.position = point1;
        wheel_2.position = point2;
        [self addChild:wheel_1];
        [self addChild:wheel_2];
        
        // word
        CGFloat fontSize = size.width*0.5 / [word length];
        wordLabel = [CCLabelTTF labelWithString:_word fontName:@"DENNE|Sketchy" fontSize:fontSize];
        wordLabel.color = ccBLACK;
        wordLabel.position = center;
        [self addChild:wordLabel];
    }
    return self;
}

- (void) runTo:(CGPoint)t_position withDuration:(ccTime)_duration
{
    BOOL isForward = YES;
    if (self.position.x > t_position.x)
    {
        isForward = NO;
        [self setFlipX:YES];
    }
    
    self.position = ccp(self.position.x, t_position.y);
    CCMoveTo *move = [CCMoveTo actionWithDuration:_duration position:t_position];
    [self runAction:move];
    
    //wheel rotate
    float rotation = 36;
    if (!isForward) rotation = -36;
    CCRotateBy *rotate1 = [CCRotateBy actionWithDuration:0.1f angle:rotation];
    CCRepeat *repeat1 = [CCRepeat actionWithAction:rotate1 times:_duration*10];
    [wheel_1 runAction:repeat1];
    
    CCRotateBy *rotate2 = [CCRotateBy actionWithDuration:0.1f angle:rotation];
    CCRepeat *repeat2 = [CCRepeat actionWithAction:rotate2 times:_duration*10];
    [wheel_2 runAction:repeat2];
}

- (void) dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end
