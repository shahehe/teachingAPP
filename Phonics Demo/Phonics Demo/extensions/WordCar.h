//
//  WordCar.h
//  Letter Games HD
//
//  Created by USTB on 12-12-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface WordCar : CCSprite
{
    CCSprite *wheel_1;
    CCSprite *wheel_2;
    
    CCLabelTTF *wordLabel;
    
    NSString *_word;
}

@property (nonatomic,copy) NSString *word;

+ (id) CarWithIndex:(NSUInteger)index andWord:(NSString*)word;

- (id) initWithIndex:(NSUInteger)index andWord:(NSString*)word;

- (void) runTo:(CGPoint) _position withDuration:(ccTime) _duration;

@end
