//
//  CardMatchingLevelDoneLayer.h
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CardMatchingLevelDoneLayer : CCLayer
{
    CCSprite *backBoard;
    
    CGPoint boardHidePosition;
    CGPoint boardShowPosition;
    
    CCLabelBMFont *levelLabel;
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *timeLabel;
    
    BOOL isShow;
    
    NSInteger remainTime;
    NSUInteger timeReduceRate;
    
    NSUInteger displayScore;
}

+ (CCScene*) scene;

- (void) hideWithDuration:(ccTime)_duration;

- (void) showWithDuration:(ccTime)_duration;

- (void) preareWithLevelIndex:(NSUInteger)index andScore:(NSUInteger)score andTime:(NSInteger)time;

@end
