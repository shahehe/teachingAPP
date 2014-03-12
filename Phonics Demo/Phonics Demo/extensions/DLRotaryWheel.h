//
//  DLRotaryWheel.h
//  little games
//
//  Created by yiplee on 14-2-26.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

static CGFloat a_to_p(CGFloat a)
{
    while (a < 0) {
        a += 360;
    }
    
    while (a >= 360) {
        a -= 360;
    }
    return a;
}

@interface DLWheelLeaf : NSObject
{
    NSString *_title;
    CGFloat  _value;
    
    CGFloat _angleA,_angleB;
}

@property(nonatomic,copy) NSString *title;
@property(nonatomic,assign) CGFloat value;
@property(nonatomic,assign) CGFloat angleA,angleB;

+ (DLWheelLeaf*) leafWithValue:(CGFloat)value title:(NSString*)title;
+ (DLWheelLeaf*) leafWithValue:(CGFloat)value;
- (id) initWithValue:(CGFloat)value title:(NSString*)title;

- (CGFloat) leafAngle;

@end

@protocol DLRotaryWheelDelegate <NSObject>

@optional

- (void) rotaryWheelStart:(id) sender;
- (void) rotaryWheelStop:(DLWheelLeaf*)leaf sender:(id) sender;

@end

@interface DLRotaryWheel : CCLayer
{
    CCNode *_container;
    CCSprite *_wheel;
    
    //转轮页面
    NSArray *_leaves;
    
    id<DLRotaryWheelDelegate> _delegate;
    
    CGFloat _defaultSelectAngle;
}

@property (nonatomic,assign) id<DLRotaryWheelDelegate> delegate;

+ (DLRotaryWheel*) wheelWithSprite:(CCSprite*) wheel wheelLeaves:(NSArray*)leaves;

- (id) initWithSprite:(CCSprite*) wheel wheelLeaves:(NSArray*)leaves;

- (NSUInteger) countOfLeaves;

- (void) setDefaultSelectAngle:(CGFloat)angle;
- (CGFloat) defaultSelectAngle;

//- (void) refreshLeavesWithAngle:(CGFloat)angle;

- (void) launchWithResult:(NSUInteger)index;

/*
// create a random result;
*/
//- (void) launchWithRandomResult;

//- (void) prepareToStop;
- (void) stop;

- (DLWheelLeaf*) leafSelectedByAngle:(CGFloat)angle;
- (DLWheelLeaf*) leafSelectedDefault;

@end
