//
//  Tiger.h
//  Letter Games HD
//
//  Created by USTB on 12-11-29.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Tiger : CCSprite
{
    CCAction *currentAnimate;
}

+ (id) newTiger;

- (id) initTiger;

- (void) speakWithDuration:(ccTime)_duration;

- (void) wagsTailWithDuration:(ccTime)_duration;

- (void) shakingHeadWithDuration:(ccTime)_duration;

@end
