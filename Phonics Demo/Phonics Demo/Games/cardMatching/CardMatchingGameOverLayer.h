//
//  CardMatchingGameOverLayer.h
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CardMatchingGameOverLayer : CCLayer
{
    CCSprite *backBoard;
    CGPoint boardShowPoint;
    CGPoint boardHidePoint;
    
    CCLabelBMFont *scoreLabel;
    
    CCMenu *menu;
    CGPoint menuShowPoint;
    CGPoint menuHidePoint;
    
    BOOL isShow;
}

+ (CCScene*) scene;

- (void) hideWithDuration:(ccTime)_duration;

- (void) showWithDuration:(ccTime)_duration;

- (void) prepareWithScore:(NSUInteger)score;

@end
