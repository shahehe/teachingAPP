//
//  CardMatchingGameDoneLayer.h
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CardMatchingGameDoneLayer : CCLayer
{
    CCSprite *backBoard;
    CGPoint boardShowPoint;
    CGPoint boardHidePoint;
    
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *timeLabel;
    
    CCMenu *menu;
    CGPoint menuShowPoint;
    CGPoint menuHidePoint;
    
    BOOL isShow;
    
    NSInteger remainTime;
    NSUInteger timeReduceRate;
    
    NSUInteger displayScore;
}

+ (CCScene*) scene;

- (void) hideWithDuration:(ccTime)_duration;

- (void) showWithDuration:(ccTime)_duration;

- (void) prepareWithScore:(NSUInteger)score andTime:(ccTime)time;

@end
