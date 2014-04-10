//
//  ImageMatch.h
//  LetterE
//
//  Created by yiplee on 14-4-10.
//  Copyright 2014年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ImageMatch : CCLayer

+ (CCScene *) gameSceneWithWords:(NSArray*)words;

+ (instancetype) gameWithWord:(NSArray*)words;
- (id) initWithWords:(NSArray*)words;

@end
