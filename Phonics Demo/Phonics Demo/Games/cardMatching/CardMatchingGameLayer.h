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
#import "Tiger.h"
#import "WordCar.h"

@interface CardMatchingGameLayer : CCLayer
{
    // game data
    NSDictionary *_gameData;
    
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
    NSUInteger _currentLevel;
    NSInteger _time;
    
    NSUInteger scoreRate;
    
    BOOL isShow;
    
    Card *firstCard;
    Card *secondCard;
}

@property(nonatomic,retain) NSDictionary *gameData;

@property(nonatomic,readonly) NSInteger score;
@property(nonatomic,readonly) NSInteger time;
@property(nonatomic,readonly) NSUInteger currentLevel;

+ (CCScene*) scene;

- (id) initWithGameData:(NSDictionary*)data;

- (void) prepareLayer;

- (void) reset;

- (void) hideWithDuration:(ccTime) _duration;

- (void) showWithDuration:(ccTime) _duration;

@end

@interface NSString (cardMatching)

+ (NSString*) timeFromSecond:(NSInteger)_second;

@end
