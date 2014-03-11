//
//  DLDraggableSprite.h
//  DLDraggableSprite
//
//  Created by yiplee on 14-3-7.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "cocos2d.h"

@protocol DLDraggableSpriteDelegate <NSObject>

@optional

- (void) draggableSpriteStartMove:(id)sender;
- (void) draggableSpriteEndMove:(id)sender;

@end

@interface DLDraggableSprite : CCSprite <CCTouchOneByOneDelegate>
{
    
}

@property(nonatomic,assign) BOOL isDraggable;
@property(nonatomic,assign,readonly) BOOL isMoving;

@property(nonatomic,assign) id<DLDraggableSpriteDelegate> delegate;

@end
