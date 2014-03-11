//
//  LetterIdentification_A.h
//  Phonics Demo
//
//  Created by yiplee on 13-7-27.
//  Copyright 2013年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "DialogContentLayer.h"

@interface LetterIdentification : DialogContentLayer {
    CCSprite *_tool;
    CCRenderTexture *_rtDetection;
    
}

- (id) initWithInitOptions:(NSDictionary *)options;

@end
