//
//  LetterGrid.h
//  Phonics Games
//
//  Created by yiplee on 14-4-6.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LetterGrid : CCSprite

@property(nonatomic,assign) char letter;
@property(nonatomic,assign) CGPoint gridIndex;

+ (instancetype) gridWithSize:(CGSize)size letter:(char)letter;
- (id) initWithSize:(CGSize)size letter:(char)letter;

@end
