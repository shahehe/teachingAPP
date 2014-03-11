//
//  SideOption.h
//  Phonics Demo
//
//  Created by yiplee on 13-8-20.
//  Copyright 2013年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SlidePauseMenuLayer : CCLayer

+ (CCScene *) slidePauseMenuWithSourceScene:(CCScene *)s_scene;
+ (CCScene *) slidePauseMenu;

- (id) initWithSourceScene:(CCScene *)s_source;

//blocks
- (void) setContinueButtonBlock:(void (^)(id sender))block;
- (void) setRestartButtonBlock:(void (^)(id sender))block;
- (void) setMenuButtonBlock:(void (^)(id sender))block;
- (void) setHelpButtonBlock:(void (^)(id sender))block;

// music on : 0 ;
// music off: 1 ;
- (void) setMusicToggleBlock:(void (^)(id sender))block;

@end
