//
//  ImageCardPro.m
//  LetterE
//
//  Created by yiplee on 14-4-10.
//  Copyright 2014年 USTB. All rights reserved.
//

#import "ImageCardPro.h"

@implementation ImageCardPro

+ (instancetype) cardWithWord:(NSString *)word
{
    return [[[self alloc] initWithWord:word] autorelease];
}

- (id) initWithWord:(NSString *)word
{
    self = [super initWithSpriteFrameName:@"card.png"];
    
    self.word = [[word lowercaseString] copy];
    
    NSString *frameName = [self.word stringByAppendingPathExtension:@"png"];
    CCSprite *image = [CCSprite spriteWithSpriteFrameName:frameName];
    
    CGPoint p_size = ccpFromSize(self.boundingBox.size);
    image.position = ccpCompMult(p_size, ccp(0.5, 0.65));
    [self addChild:image z:1];
    
    self.scale = 2;
    
    CCSprite *labelBox = [CCSprite spriteWithSpriteFrameName:@"word_box.png"];
    labelBox.position = ccpCompMult(p_size, ccp(0.5,0.20));
    [self addChild:labelBox z:2];
    
    labelBox.scale = 0.5;
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:word fontName:@"Gill Sans" fontSize:32];
    label.color = ccBLACK;
    label.position = labelBox.position;
    [self addChild:label z:3];
    
    return self;
}

- (void) dealloc
{
    [_word release];
    [super dealloc];
}

@end
