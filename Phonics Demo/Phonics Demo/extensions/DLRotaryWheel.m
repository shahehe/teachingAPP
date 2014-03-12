//
//  DLRotaryWheel.m
//  little games
//
//  Created by yiplee on 14-2-26.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "DLRotaryWheel.h"



@implementation DLWheelLeaf

@synthesize title = _title;
@synthesize value = _value,angleA = _angleA,angleB = _angleB;

+ (DLWheelLeaf*) leafWithValue:(CGFloat)value title:(NSString *)title
{
    return [[[[self class] alloc] initWithValue:value title:title] autorelease];
}

+ (DLWheelLeaf*) leafWithValue:(CGFloat)value
{
    return [[[self class] leafWithValue:value title:nil] autorelease];
}

- (id) initWithValue:(CGFloat)value title:(NSString *)title
{
    if (self = [super init])
    {
        NSAssert(value > 0, @"value for a leaf can't be negative");
        
        _value = value;
        self.title = title;
        _angleA = _angleB = 0;
    }
    return self;
}

- (CGFloat) leafAngle
{
    CGFloat angle = _angleB - _angleA;
    angle = angle < 0 ? angle + 360 : angle;
    
    return angle;
}

@end


@implementation DLRotaryWheel
{
    
}

+ (DLRotaryWheel*) wheelWithSprite:(CCSprite *)wheel wheelLeaves:(NSArray *)leaves
{
    return [[[[self class] alloc] initWithSprite:wheel wheelLeaves:leaves] autorelease];
}

- (id) initWithSprite:(CCSprite *)wheel wheelLeaves:(NSArray *)leaves
{
    if (self = [super init])
    {
        CGSize size = [[CCDirector sharedDirector] winSize];
        CGPoint size_p = ccpFromSize(size);
        
        NSAssert(wheel, @"DLRotaryWheel:sprite is nil");
        _wheel = wheel;
        _wheel.position = ccpMult(size_p, 0.5);
        [self addChild:_wheel z:1];
        
        _leaves = [[NSArray alloc] initWithArray:leaves];
        
        CGFloat sum = 0;
        for (DLWheelLeaf *leaf in _leaves) {
            sum += leaf.value;
        }
        
        _defaultSelectAngle = 0;
        
        CGFloat angle = 0 , t_angle = _defaultSelectAngle;
        for (DLWheelLeaf *leaf in _leaves) {
            angle = leaf.value / sum * 360;
            leaf.angleA = t_angle;
            leaf.angleB = t_angle + angle;
            t_angle = leaf.angleB;
        }
        
        DLWheelLeaf *firstLeaf = (DLWheelLeaf*)[_leaves firstObject];
        [self refreshLeavesWithAngle:-[firstLeaf leafAngle]/2];
    }
    return self;
}

- (void) dealloc
{
    [_leaves release];
    _leaves = nil;
    
    [super dealloc];
}

- (NSUInteger) countOfLeaves
{
    return [_leaves count];
}

- (CGPoint) position
{
    return _wheel.position;
}

- (void) setPosition:(CGPoint)position
{
    _wheel.position = position;
}

- (void) setDefaultSelectAngle:(CGFloat)angle
{
    _defaultSelectAngle = a_to_p(angle);
}

- (CGFloat) defaultSelectAngle
{
    return _defaultSelectAngle;
}

- (void) refreshLeavesWithAngle:(CGFloat)angle
{
    for (DLWheelLeaf *leaf in _leaves)
    {
        leaf.angleA = a_to_p(leaf.angleA + angle);
        leaf.angleB = a_to_p(leaf.angleB + angle);
    }
}

- (void) rotateWithDegree:(CGFloat)degree
{
    static CGFloat averageSpeed = 360;
    CCRotateBy *rotate = [CCRotateBy actionWithDuration:degree/averageSpeed
                                                  angle:degree];
    
    CCEaseExponentialOut *ease = [CCEaseExponentialOut actionWithAction:rotate];
    CCCallFunc *end = [CCCallFunc actionWithTarget:self selector:@selector(stop)];
    CCSequence *seq = [CCSequence actions:ease,end, nil];
    [_wheel runAction:seq];
    
    [self refreshLeavesWithAngle:degree];
}

- (void) launchWithResult:(NSUInteger)index
{
    NSUInteger _index = index % [self countOfLeaves];
    DLWheelLeaf *leaf = [_leaves objectAtIndex:_index];
    CCLOG(@"target:%i",_index);
    CGFloat angle = leaf.angleB - leaf.angleA;
    angle = a_to_p(angle);
    angle = (CCRANDOM_0_1() *0.4 + 0.3) * angle + leaf.angleA;
    angle = a_to_p(_defaultSelectAngle - angle);
    
    CGFloat turn = floor(CCRANDOM_0_1() * 3) + 2;
    angle = angle + turn * 360;
    
    [self rotateWithDegree:angle];
    
    if ([_delegate respondsToSelector:@selector(rotaryWheelStart:)])
    {
        [_delegate rotaryWheelStart:self];
    }
}

- (void) stop
{
    [_wheel stopAllActions];
    
    if ([_delegate respondsToSelector:@selector(rotaryWheelStop:sender:)])
    {
        DLWheelLeaf *leaf = [self leafSelectedDefault];
        [_delegate rotaryWheelStop:leaf sender:self];
    }
}

- (DLWheelLeaf*) leafSelectedByAngle:(CGFloat)angle
{
    for (DLWheelLeaf *leaf in _leaves)
    {
        CGFloat b = leaf.angleB;
        CGFloat a = leaf.angleA;
        CCLOG(@"find %f from %f to %f",angle,a,b);
        if (b < a) a -= 360;
        
        if (angle > a && angle <= b)
            return leaf;
    }
    CCLOG(@"can't find leaf");
    return nil;
}

- (DLWheelLeaf *) leafSelectedDefault
{
    return [self leafSelectedByAngle:_defaultSelectAngle];
}

@end
