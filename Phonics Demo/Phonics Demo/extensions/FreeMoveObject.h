//
//  MyCocos2DClass.h
//  Letter Games HD
//
//  Created by USTB on 12-11-24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FreeMoveObject : CCSprite
{
    CGFloat _moveSpeed;
    CGFloat _rotateSpeed;
    CGFloat _startRotation;
    CGPoint _targetPosition;
    
    CGRect _movingRect;
    
    //speed rate
    BOOL isMoving;
    NSUInteger speedRate;
    CCSpeed *speed;
}

@property (nonatomic,readwrite) CGFloat moveSpeed;
@property (nonatomic,readwrite) CGFloat rotateSpeed;
@property (nonatomic,readonly) CGFloat startRotation;
@property (nonatomic,readonly) CGPoint targetPosition;
@property (nonatomic,readwrite) CGRect movingRect;

+ (id) objectWithFile:(NSString*)fileName startRotation:(CGFloat) rotation;

+ (id) objectWithSpriteFrameName:(NSString*)spriteFrameName startRotation:(CGFloat) rotation;

- (id) initWithFile:(NSString *)filename startRotation:(CGFloat) rotation;

- (id) initWithSpriteFrameName:(NSString *)spriteFrameName startRotation:(CGFloat) rotation;

- (void) moveToPosition:(CGPoint)position;

- (void) beClicked;

@end
