//
//  LetterGrid.m
//  Phonics Games
//
//  Created by yiplee on 14-4-6.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "LetterGrid.h"

@implementation LetterGrid

+ (instancetype) gridWithSize:(CGSize)size letter:(char)letter
{
    return [[[[self class] alloc] initWithSize:size letter:letter] autorelease];
}

- (id) initWithSize:(CGSize)size letter:(char)letter
{
    self = [super initWithFile:@"blockTexture.png" rect:CGRectMake(0, 0, size.width, size.height)];
    
    ccTexParams params =
    {
        GL_LINEAR,
        GL_LINEAR,
        GL_REPEAT,
        GL_REPEAT
    };
    [self.texture setTexParameters:&params];
    
    _letter = letter;
    _gridIndex = CGPointZero;
    
    return self;
}

@end
