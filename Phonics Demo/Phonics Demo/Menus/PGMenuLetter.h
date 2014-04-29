//
//  PGMenuLetter.h
//  LetterE
//
//  Created by yiplee on 4/29/14.
//  Copyright 2014 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PGMenuLetter : CCLayer

+ (CCScene *) menuWithLetter:(char)letter;

- (id) initWithLetter:(char)letter;

@end
