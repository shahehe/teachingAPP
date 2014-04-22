//
//  bubble.m
//  bubble
//
//  Created by yiplee on 13-3-31.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import "bubble.h"
#import "chipmunk_unsafe.h"
#import "BubbleConfig.h"

@implementation bubble
{
    cpBody *_body;
}

@dynamic pos;

- (void) setPos:(cpVect)pos
{
    cpBodySetPos(_body, pos);
}

- (cpVect) pos
{
    return cpBodyGetPos(_body);
}

- (id) initWithObjectInside:(CCPhysicsSprite*)object
{
    if (self = [super init])
    {
        _bubbleType = BubbleTypeNormal; // 普通泡泡
        _isObjectPerformScale = NO;     // 默认泡泡内物体不变大
        _scaleRate = 1;
        
        _bubble = [[CCPhysicsSprite alloc] initWithSpriteFrameName:@"game_bubble.png"];
        
        // 半径
        cpFloat radius = _bubble.contentSize.width*0.5f*_scaleRate;
        // 质量
        cpFloat mass = 0.6*radius*radius*radius;
        
        // physic body
        _body = cpBodyNew(mass, cpMomentForCircle(mass, 0.0f, radius, cpvzero));
        // atach self to physics body in order to get pointer to self in physics callback
        cpBodySetUserData(_body, self);
        
        // physic shape
        _shape = cpCircleShapeNew(_body, radius-2, cpvzero);
        cpShapeSetFriction(_shape, 0.5f);   //摩擦力
        cpShapeSetElasticity(_shape, 1.0f); //弹性
        cpShapeSetLayers(_shape, PhysicsBubbleLayers);
        // atach self to physics shape in order to get pointer to self in physics callback
        cpShapeSetUserData(_shape, self);
        
        _bubble.CPBody = _body;
        
        // 默认泡泡是不旋转的，里面的物体是会旋转的
        _bubble.ignoreBodyRotation = TRUE;
        
        _object = object;
        if (_object)
        {
            _object.CPBody = _body;
            [_object retain];
            
            _object.ignoreBodyRotation = TRUE;
        }
    }
    return self;
}

+ (bubble*) bubbleWithObject:(CCPhysicsSprite *)object
{
    return [[[self alloc] initWithObjectInside:object] autorelease];
}

- (void) setScaleRate:(CGFloat)scaleRate
{
    if (_scaleRate == scaleRate) return;
    
    _scaleRate = scaleRate;
    _bubble.scale = scaleRate;
    if (_isObjectPerformScale && _object)
        _object.scale = scaleRate;
    
    // update shape
    cpCircleShapeSetRadius(_shape, _bubble.boundingBox.size.width/2-2);
}

- (void) addToSpace:(cpSpace *)space
{
    cpSpaceAddBody(space, _body);
    cpSpaceAddShape(space, _shape);
}

- (void) removeFromSpace:(cpSpace *)space
{
    cpSpaceRemoveBody(space, _body);
    cpSpaceRemoveShape(space, _shape);
}

- (void) showObject
{
    _bubble.visible = NO;
}

- (void) dealloc
{
    [_bubble release];
    _bubble = nil;
    [_object release];
    _object = nil;
    cpBodyFree(_body);
    cpShapeFree(_shape);
    
    [super dealloc];
}

@end
