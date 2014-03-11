//
//  DLDraggableSprite.m
//  DLDraggableSprite
//
//  Created by yiplee on 14-3-7.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "DLDraggableSprite.h"

@implementation DLDraggableSprite
{
    CGPoint touchPosition;
    
    BOOL _isMoving;
}

@synthesize isMoving = _isMoving;

- (id) init
{
    if (self = [super init])
    {
        _isDraggable = NO;
        _isMoving = NO;
    }
    return self;
}

- (void) dealloc
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    [super dealloc];
}

- (BOOL) draggable
{
    return _isDraggable;
}

- (void) setIsDraggable:(BOOL)isDraggable
{
    if (_isDraggable == isDraggable)
        return;
    
    _isDraggable = isDraggable;
    if (_isDraggable)
    {
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    else
    {
        [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    }
}

#pragma mark --CCTouchOneByOneDelegate

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!self.visible)
        return NO;
    
    CGPoint pos = [self convertTouchToNodeSpace:touch];
    CGRect rect = self.boundingBox;
    rect.origin = CGPointZero;
    
    if (CGRectContainsPoint(rect, pos))
    {
        touchPosition = pos;
        
        if ([_delegate respondsToSelector:@selector(draggableSpriteStartMove:)])
        {
            [_delegate draggableSpriteStartMove:self];
        }
        
        _isMoving = YES;
        
        return  YES;
    }
    
    return NO;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!_isDraggable) return;
    
    CGPoint pos = [self convertTouchToNodeSpace:touch];
    self.position = ccpAdd(self.position, ccpSub(pos, touchPosition));
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(draggableSpriteEndMove:)])
    {
        [_delegate draggableSpriteEndMove:self];
    }
    
    _isMoving = NO;
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(draggableSpriteEndMove:)])
    {
        [_delegate draggableSpriteEndMove:self];
    }
    
    _isMoving = NO;
}

@end
