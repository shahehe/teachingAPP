//
//  ExtraAction.m
//  BookReader
//
//  Created by USTB on 12-11-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ExtraAction.h"


@implementation ExtraAction


@end

@implementation CCNode (yipleeAction)

- (void) shakeWithRound:(NSUInteger)round
{
    CCMoveBy *move01 = [CCMoveBy actionWithDuration:0.08 position:ccp(10, 0)];
    CCEaseOut *ease01 = [CCEaseOut actionWithAction:move01 rate:4];
    
    CCMoveBy *move02 = [CCMoveBy actionWithDuration:0.16 position:ccp(-20, 0)];
    CCEaseInOut *ease02 = [CCEaseInOut actionWithAction:move02 rate:4];
    
    CCMoveBy *move03 = [CCMoveBy actionWithDuration:0.08 position:ccp(10, 0)];
    CCEaseIn *ease03 = [CCEaseIn actionWithAction:move03 rate:4];
    
    CCSequence *seq = [CCSequence actions:ease01,ease02,ease03, nil];
    
    CCRepeat *repeat = [CCRepeat actionWithAction:seq times:round];
    
    [self runAction:repeat];
    
}

@end
