//
//  CCSprite+CustomOptions.m
//  Phonics Demo
//
//  Created by yiplee on 13-7-24.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import "Cocos2d+CustomOptions.h"

@implementation CCSprite (CustomOptions)

- (void) setFrame:(CGRect) frame
{
    self.scaleX = frame.size.width / self.contentSize.width;
    self.scaleY = frame.size.height / self.contentSize.height;
    
    [self setBoundingBoxCenterOfRect:frame];
}

- (void) fitSize:(CGSize)size scaleIn:(BOOL)scaleIn
{
    CGSize origin = self.boundingBox.size;
    CGFloat ratio = MIN(size.width/origin.width, size.height/origin.height);
    
    if (ratio > 1 && !scaleIn)
        return;
    
    self.scale = ratio;
}

- (void) setWidth:(CGFloat)width
{
    self.scaleX = width / self.contentSize.width;
}

- (void) setHeight:(CGFloat)height
{
    self.scaleY = height / self.contentSize.height;
}

- (void) setBoundingBoxCenterOfRect:(CGRect) rect
{
    self.position = ccpAdd(rect.origin, ccpCompMult(ccpFromSize(rect.size), self.anchorPoint));
}

- (void) setPositionCenterOfRect:(CGRect) rect
{
    self.position = ccpAdd(rect.origin, ccpMult(ccpFromSize(rect.size), 0.5));
}

- (void) setBoundingBoxCenterOfParent
{
    if (!self.parent) return;
    CGSize size = self.parent.boundingBox.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [self setBoundingBoxCenterOfRect:rect];
}

@end

@implementation CCLayer (CustomOptions)

- (void) addBackgroundImageWithFile:(NSString *)fileName fitScreen:(BOOL)fit
{
    CCSprite *backgroundImage = [CCSprite spriteWithFile:fileName];
    
    if (fit)
        [backgroundImage setFrame:self.boundingBox];
    else [backgroundImage setBoundingBoxCenterOfRect:self.boundingBox];
    
    [self addChild:backgroundImage z:NSIntegerMin tag:2222];
}

- (void) addBackgroundImageWithSpriteFrameName:(NSString *)spriteFrameName fitScreen:(BOOL)fit
{
    CCSprite *backgroundImage = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
    
    if (fit)
        [backgroundImage setFrame:self.boundingBox];
    else [backgroundImage setBoundingBoxCenterOfRect:self.boundingBox];
    
    [self addChild:backgroundImage z:NSIntegerMin];
}

@end
