//
//  Cards.h
//  BookReader
//
//  Created by USTB on 12-11-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    FlipFromLeft = 0,
    FlipFromRight,
    FlipFromUp,
    FlipFromDown
}FlipDirection;

@interface Card : CCSprite
{
    CCSprite *_frontImg; //weak ref
    CCSprite *_backImg;  //weak ref
    
    NSString *_word;
    
    BOOL _isShow;
}

@property(nonatomic,copy)NSString *word;
@property(nonatomic,readonly)CCSprite *frontImg;
@property(nonatomic,readonly)CCSprite *backImg;
@property(nonatomic,readonly)BOOL isShow;

+ (id) cardWithCardWord:(NSString*)word;

- (id) initWithCardWord:(NSString*)word;

+ (id) cardWithWord:(NSString*)word frontImg:(CCSprite*)frontImg backImg:(CCSprite*)backImg;

- (id) initWithWord:(NSString*)word frontImg:(CCSprite*)frontImg backImg:(CCSprite*)backImg;

- (void) showFromDirection:(FlipDirection)_direction withDuration:(ccTime)_duration;

- (void) hideFromDirection:(FlipDirection)_direction withDuration:(ccTime)_duration;

- (void) flipCardFromDirection:(FlipDirection)_direction withDuration:(ccTime)_duration;

- (void) showDirect;

- (void) hideDirect;

- (BOOL) isMatchWithCard:(Card*) _card;

@end
