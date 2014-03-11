//
//  ToolbarLayer.h
//  Phonics Demo
//
//  Created by yiplee on 13-7-22.
//  Copyright 2013年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ToolbarLayer : CCLayer
{
@private
    CCLayerColor    *_backgroundLayer;
    CCSprite        *_backgroundSprite;
    CCMenu          *_toolbarMenu;
    
    NSTimeInterval  _tickTime;
}

@property (nonatomic,assign) CGFloat barWidth;
@property (nonatomic,assign) CGFloat barHeight;

@property (nonatomic,retain) CCSpriteFrame  *backgroundSpriteFrame;
@property (nonatomic,assign) ccColor4F      backgroundColor;

// default is 84
@property (nonatomic,assign) CGFloat sidePadding;
//default is 160
@property (nonatomic,assign) CGFloat itemPadding;

// CCMenuItems,default is nil
@property (nonatomic,retain) NSArray *leftItems;
@property (nonatomic,retain) NSArray *rightItems;

// title,default is nil
@property (nonatomic,retain) CCNode *titleNode;

@property (nonatomic,readonly,getter = isHidden) BOOL hidden;
@property (nonatomic,assign) BOOL autoHide;

- (void) active;

- (void) toolbarShowWithAnimation:(BOOL)isAnimation;
- (void) toolbarHideWithAnimation:(BOOL)isAniamtion;

- (void) addAdditionalMenuItem:(CCMenuItem *)item;

@end


