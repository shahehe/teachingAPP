//
//  Dialog.h
//  Phonics Demo
//
//  Created by yiplee on 13-7-26.
//  Copyright 2013年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class DialogContentLayer;
@class ToolbarLayer;

typedef NS_ENUM(NSInteger, DialogContentType)
{
    DialogContentTypeLetterIdentification = 0,
    DialogContentTypeSound,
    DialogContenttypePuzzle,
    DialogContentTypePoem,
};



@interface Dialog : CCLayer

@property (nonatomic,retain,readonly) DialogContentLayer *contentlayer;
@property (nonatomic,retain,readonly) ToolbarLayer       *toolbarLayer;

+ (CCScene*) scene DEPRECATED_ATTRIBUTE;
- (id) init;

// added at 08/03
+ (CCScene *)dialogWithContentLayer:(DialogContentLayer *)contentLayer;
+ (CCScene *)dialogWithContentLayerType:(DialogContentType)contentType letter:(char)letter;
- (id) initWithContentLayer:(CCLayer *)contentLayer;

@end
