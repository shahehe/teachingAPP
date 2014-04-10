//
//  CCSprite+CustomOptions.h
//  Phonics Demo
//
//  Created by yiplee on 13-7-24.
//  Copyright (c) 2013年 USTB. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCSprite (CustomOptions)

- (void) setFrame:(CGRect) frame;

- (void) fitSize:(CGSize)size scaleIn:(BOOL)scaleIn;

- (void) setWidth:(CGFloat) width;
- (void) setHeight:(CGFloat) height;

- (void) setBoundingBoxCenterOfRect:(CGRect) rect;
- (void) setPositionCenterOfRect:(CGRect) rect;

- (void) setBoundingBoxCenterOfParent;

@end

@interface CCLayer (CustomOptions)

- (void) addBackgroundImageWithFile:(NSString*)fileName fitScreen:(BOOL)fit;

- (void) addBackgroundImageWithSpriteFrameName:(NSString *)spriteFrameName fitScreen:(BOOL)fit;

@end
