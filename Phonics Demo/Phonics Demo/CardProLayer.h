//
//  CardProLayer.h
//  LetterE
//
//  Created by yiplee on 14-4-10.
//  Copyright 2014年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CardProLayer : CCLayer

@property(nonatomic,unsafe_unretained) CCScene *sourceScene;

+ (instancetype) layerWithWord:(NSString*)word;

- (id) initWithWord:(NSString*)word;

@end
