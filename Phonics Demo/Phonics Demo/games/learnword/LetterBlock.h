//
//  LetterBlock.h
//  Phonics Games
//
//  Created by yiplee on 14-4-1.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LetterBlock : CCPhysicsSprite

@property (nonatomic,readonly) char letter;
@property(nonatomic, readonly) cpShape *shape;

+ (instancetype) blockWithSize:(CGSize)size letter:(char)letter;
+ (instancetype) blockWithFile:(NSString*)file letter:(char)letter;

- (id) initWithSize:(CGSize)size letter:(char)letter;
- (id) initWithFile:(NSString*)file letter:(char)letter;

- (void) addToSpace:(cpSpace*)space;
- (void) removeFromSpace:(cpSpace*)space;

@end
