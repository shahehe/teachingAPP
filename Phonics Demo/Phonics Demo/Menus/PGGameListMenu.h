//
//  PGGameListMenu.h
//  Phonics Games
//
//  Created by yiplee on 14-4-7.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PGGameListMenu : CCLayer

+ (CCScene *) menuWithLetter:(char)letter;

- (id) initWithLetter:(char)letter;

@end
