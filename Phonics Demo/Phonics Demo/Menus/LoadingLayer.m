//
//  LoadingLayer.m
//  Phonics Games
//
//  Created by yiplee on 14-4-8.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "LoadingLayer.h"
#import "PhonicsDefines.h"

@implementation LoadingLayer

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [[self class] node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    self = [super init];
    
    CCLabelTTF *loading = [CCLabelTTF labelWithString:@"LOADING" fontName:@"Superclarendon-Bold" fontSize:32];
    loading.position = CCMP(0.5, 0.5);
    [self addChild:loading];
    
//    CCFadeIn *fade = [CCFadeIn actionWithDuration:0.2];
//    CCRotateBy *rotate = [CCRotateBy actionWithDuration:0.1 angle:360];
//    CCSequence *s = [CCSequence actions:fade,rotate, nil];
//    
//    [loading runAction:[CCRepeatForever actionWithAction:fade]];
    
    return self;
}

@end
