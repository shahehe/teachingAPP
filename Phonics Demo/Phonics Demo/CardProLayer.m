//
//  CardProLayer.m
//  LetterE
//
//  Created by yiplee on 14-4-10.
//  Copyright 2014年 USTB. All rights reserved.
//

#import "CardProLayer.h"
#import "ImageCardPro.h"

#import "PhonicsDefines.h"

@implementation CardProLayer

+ (instancetype) layerWithWord:(NSString *)word
{
    return [[[self alloc] initWithWord:word] autorelease];
}

- (id) initWithWord:(NSString *)word
{
    self = [super init];
    
    CCLayerColor *bgLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 153)];
    [self addChild:bgLayer z:0];
    
    ImageCardPro *card = [ImageCardPro cardWithWord:word];
    card.position = CCMP(0.5, 0.5);
    [self addChild:card z:1];
    
    CCSprite *close = [CCSprite spriteWithSpriteFrameName:@"close.png"];
    
    CCMenuItemSprite *closeButton = [CCMenuItemSprite itemWithNormalSprite:close selectedSprite:nil block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
    closeButton.position = ccpAdd(ccpCompMult(ccpFromSize(card.boundingBox.size), ccp(1,1)),card.boundingBox.origin);
    
    CCMenu *menu = [CCMenu menuWithItems:closeButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:2];
    
    return self;
}

- (void) draw
{
    [super draw];
    
    [_sourceScene visit];
}

@end
