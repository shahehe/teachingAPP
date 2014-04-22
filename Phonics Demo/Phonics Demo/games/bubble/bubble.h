//
//  bubble.h
//  bubble
//
//  Created by yiplee on 13-3-31.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    BubbleTypeNormal = 0,  // 普通泡泡
    BubbleTypeLetter,       // 字母泡泡
    BubbleTypeProps         // 道具泡泡
}BubbleType;

@interface bubble : NSObject

@property(nonatomic, assign) cpVect pos;
@property(nonatomic, readonly) cpShape *shape;
@property(nonatomic,assign) BubbleType bubbleType;
@property(nonatomic,strong,readonly) CCPhysicsSprite *bubble;
// the object in bubble
@property(nonatomic,strong,readonly) CCPhysicsSprite *object;

// 泡泡里面的物体是否随着泡泡变大而变大?
@property(nonatomic,assign) BOOL isObjectPerformScale;

// 泡泡的 scale rate
@property(nonatomic,assign) CGFloat scaleRate;

- (id) initWithObjectInside:(CCPhysicsSprite*)object;
+ (bubble*) bubbleWithObject:(CCPhysicsSprite*)object;

// 添加自己到一个 chipmunk space
- (void) addToSpace:(cpSpace*)space;

// 将自己从一个 chipmunk space 移除
- (void) removeFromSpace:(cpSpace*)space;

- (void) showObject;

@end
