//
//  TraceUtil.h
//  Phonics Demo
//
//  Created by Yan Feng on 11/14/13.
//  Copyright 2013 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TraceUtil : CCNode {
    
}
@property   (nonatomic, strong) CCSprite *mySprite;
-(id)   initWithPositionX: (int) positionX
                PositionY: (int) positionY
                    Scale: (float) scale
                     Name: (NSString *) name;
-(BOOL) pointIsOutOfTheBound:(CGPoint)  point;

@end
