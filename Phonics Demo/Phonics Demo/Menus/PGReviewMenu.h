//
//  PGReviewMenu.h
//  LetterE
//
//  Created by yiplee on 4/28/14.
//  Copyright 2014 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PGReviewMenu : CCLayer

+ (CCScene *) menuWithLetter:(char)letter;

- (id) initWithLetter:(char)letter;

@end
