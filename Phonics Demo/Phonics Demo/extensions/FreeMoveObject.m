//
//  MyCocos2DClass.m
//  Letter Games HD
//
//  Created by USTB on 12-11-24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "FreeMoveObject.h"


@implementation FreeMoveObject

@synthesize moveSpeed = _moveSpeed;
@synthesize rotateSpeed = _rotateSpeed;
@synthesize startRotation = _startRotation;
@synthesize targetPosition = _targetPosition;
@synthesize movingRect = _movingRect;

+ (id) objectWithFile:(NSString *)fileName startRotation:(CGFloat) rotation
{
    return [[[self alloc] initWithFile:fileName startRotation:rotation] autorelease];
}

+ (id) objectWithSpriteFrameName:(NSString *)spriteFrameName startRotation:(CGFloat) rotation
{
    return [[[self alloc] initWithSpriteFrameName:spriteFrameName startRotation:rotation] autorelease];
}

- (id) initWithFile:(NSString *)filename startRotation:(CGFloat) rotation
{
    if (self = [super initWithFile:filename])
    {
        _moveSpeed = 1;
        _rotateSpeed = 90;
        _startRotation = rotation;
        _targetPosition = ccp(0, 0);
        speedRate = 1;
        isMoving = NO;
        _movingRect = CGRectMake(0, 0, 0, 0);
    }
    return self;
}

- (id) initWithSpriteFrameName:(NSString *)spriteFrameName startRotation:(CGFloat) rotation
{
    if (self = [super initWithSpriteFrameName:spriteFrameName])
    {
        _moveSpeed = 1;
        _rotateSpeed = 90;
        _startRotation = rotation;
        _targetPosition = ccp(0, 0);
        speedRate = 1;
        isMoving = NO;
        _movingRect = CGRectMake(0, 0, 0, 0);
    }
    return self;
}

- (void) moveToPosition:(CGPoint)position
{
    CGFloat distance;
    CGFloat rotation;
    if ((distance = ccpDistance(self.position, position)) == 0) return;
    
    _targetPosition = position;
    
    CGFloat offsetY = position.y - self.position.y;
    CGFloat offsetX = position.x - self.position.x;
    
    rotation = -ccpToAngle(ccp(offsetX,offsetY))/M_PI*180 - _startRotation;
    
    CGFloat _rotateDuration = fabsf(rotation)/_rotateSpeed;
    CGFloat _moveDuration = distance/_moveSpeed;
    
    CCRotateTo *action1 = [CCRotateTo actionWithDuration:_rotateDuration angle:rotation];
    CCMoveTo *action2 = [CCMoveTo actionWithDuration:_moveDuration position:_targetPosition];
    CCCallBlock *action3 = [CCCallBlock actionWithBlock:^{
        isMoving = NO;
        speedRate = 1;
    }];
    CCSequence *seq = [CCSequence actions:action1,action2,action3,nil];
    
    if (isMoving) [self stopAction:speed];
    speed = [CCSpeed actionWithAction:seq speed:speedRate];
    [self runAction:speed];
    isMoving = YES;
}

- (void) beClicked
{
    if (isMoving) speedRate = 2;
    CGFloat x = arc4random_uniform(_movingRect.size.width);
    CGFloat y = arc4random_uniform(_movingRect.size.height);
    [self moveToPosition:ccpAdd(ccp(x, y), _movingRect.origin)];
}

- (void) dealloc
{
    [self stopAllActions];
    [super dealloc];
}


@end
