//
//  propsBubble.h
//  bubble
//
//  Created by yiplee on 13-4-2.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "bubble.h"

/**********************************
 *道具泡泡自身携带各项奖励或者惩罚指标
 *如何使用这些指标，由道具泡泡使用者自己写方法来使用
 **********************************/
@interface propsBubble : bubble

// 道具携带的分数，负代表减份，正代表加分，下同
@property(nonatomic,assign) NSInteger score;
// 道具携带的金币数
@property(nonatomic,assign) NSInteger coin;
// 道具携带的时间奖励
@property(nonatomic,assign) NSInteger time;
// 道具携带的生命奖励
@property(nonatomic,assign) NSInteger live;

- (id) initWithPropsInside:(CCPhysicsSprite *)object;
+ (propsBubble*) bubbleWithPropsInside:(CCPhysicsSprite*)props;

@end

#pragma mark -coin bubble
// 金币泡泡
@interface coinBubble : propsBubble

- (id) initBubbleWithCoin:(NSInteger)coinNumber;
+ (coinBubble*) coinBubble;
+ (coinBubble*) coinBubbleWithCoin:(NSInteger)coinNumber;

@end

#pragma mark -heart bubble

@interface heartBubble : propsBubble

@end
