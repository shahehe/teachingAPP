//
//  LetterWriting.h
//  little games
//
//  Created by yiplee on 14-2-25.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "PhonicsGameLayer.h"

@interface LetterWriting : PhonicsGameLayer {
    
}

@property(atomic,retain) NSMutableArray *correctLetterSprites;
@property(atomic,retain) NSMutableArray *incorrectLetterSprites;

@end
