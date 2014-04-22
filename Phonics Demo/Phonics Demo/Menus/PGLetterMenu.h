//
//  PGLetterMenu.h
//  LetterE
//
//  Created by yiplee on 14-4-22.
//  Copyright 2014年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PGLetterMenu : CCLayer

+ (CCScene *) menuWithLetter:(char)letter;

- (id) initWithLetter:(char)letter;

@end
