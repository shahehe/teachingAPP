//
//  CardMatchingGameLayer.h
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Card.h"
#import "WordCar.h"
#import "SimpleAudioEngine.h"

@interface CardMatchingGameLayer : CCLayer
{
    // bus area
    CCSprite *busStopPlace;  //weak ref
    CGPoint busStopShowPosition;
    CGPoint busStopHidePosition;
    CGPoint *stopPostions;
    NSUInteger nextCarIndex;
    NSUInteger numberOfShowCars;
    CCArray *cars;
    
    // pencil
    CCSprite *pencil;   //weak ref
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *levelLabel;
    CCLabelBMFont *timeLabel;
    CGPoint pencilShowPosition;
    CGPoint pencilHidePosition;
    
    // card area
    CCNode *cardPanel;
    CCArray *cards;
    CGPoint cardPanelShowPosition;
    CGPoint cardPanelHidePosition;
    NSUInteger line;
    NSUInteger row;
    NSUInteger numberOfRemainCards;
    
    // game status
    NSUInteger wordsCount;
    NSInteger _score;
    NSInteger _totalScore;
    NSUInteger _currentLevel;
    NSInteger _time;
    CGFloat cardFlipDuration;
    
    NSUInteger scoreRate;
    
    BOOL isShow;
    
    Card *firstCard;
    Card *secondCard;
}

@property(nonatomic,readwrite) NSInteger totalScore;
@property(nonatomic,readonly) NSInteger score;
@property(nonatomic,readonly) NSInteger time;
@property(nonatomic,readonly) NSUInteger currentLevel;

+ (instancetype) layerWithWords:(NSArray*)words;

- (id) initWithWords:(NSArray*)words;

- (void) prepareLayer;

- (void) reset;

- (void) hideWithDuration:(ccTime) _duration;

- (void) showWithDuration:(ccTime) _duration;

@end

@interface NSString (cardMatching)

+ (NSString*) timeFromSecond:(NSInteger)_second;

@end
