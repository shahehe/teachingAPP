//
//  ImageCardPro.h
//  LetterE
//
//  Created by yiplee on 14-4-10.
//  Copyright 2014年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ImageCardPro : CCSprite

@property(nonatomic,copy)NSString *word;

+ (instancetype) cardWithWord:(NSString*)word;
- (id) initWithWord:(NSString*)word;

@end
