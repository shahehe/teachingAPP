//
//  HamsterGameLayer.h
//  Hamster
//
//  Created by yiplee on 5/23/14.
//  Copyright 2014 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HamsterGameLayer : CCLayer

+ (instancetype) hamsterGameWithWords:(NSArray*)words;
- (id) initGameWithWords:(NSArray*)words;

@end
