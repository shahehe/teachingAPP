//
//  Gardenlayer.h
//  garden
//
//  Created by yiplee on 14-3-10.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DLDraggableSprite.h"
#import "DLSubtitleLabel.h"

@interface Gardenlayer : CCLayer<DLDraggableSpriteDelegate,DLSubtitleLabelDelegate>
{
    
}

+ (CCScene *) scene;

@end
