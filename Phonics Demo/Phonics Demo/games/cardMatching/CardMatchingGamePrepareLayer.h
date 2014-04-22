//
//  CardMatchingGamePrepareLayer.h
//  Letter Games HD
//
//  Created by USTB on 12-12-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CardMatchingGamePrepareLayer : CCLayer
{
    //CCSprite *title;
    
    CCSprite *backBoard; //weak ref
    
    //CCMenu *menu;
}

+ (CCScene*) scene;

- (void) showWithDuration:(ccTime)_duration;

- (void) hideWithDuration:(ccTime)_duration;

@end
