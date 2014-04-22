//
//  PauseMenu.h
//  phonics matching cards HD
//
//  Created by USTB on 12-12-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CardMatchPauseMenu : CCLayer {
    CCScene *sourceScene;
}

+ (CCScene*) sceneWithScene:(CCScene*)_scene;

- (id) initWithScene:(CCScene*)_scene;

@end
